#!/usr/bin/env bash
# =============================================================================
# check-leaks.sh — porte AC5 : rien de l'infrastructure interne, aucun nom de
# client, aucun appel externe ne doit se retrouver dans le contenu publié.
#
# Décisions appliquées :
#
#   D1 (13/08) — pas de regex numérique nue pour les VMID : un motif [0-9]{3}
#     déclencherait sur le contenu approuvé (1 485, 100/100, SIREN…) et la porte
#     finirait désactivée. Détection par contexte.
#   D2 (13/08) — agrégats de capacité autorisés (« 4 GPU »), noms de modèles et
#     de produits d'infrastructure interdits.
#   D-site-10 (14/08) — amendement de D2. Deux familles désormais distinguées :
#     · IDENTIFIANTS (IP, hostnames, VMID, clients) : bloqués PARTOUT ;
#     · PRODUITS ET TECHNOLOGIES PUBLIQUES (Proxmox, ZFS, RTX…) : bloqués sur la
#       vitrine, qui parle en capacités agrégées par choix éditorial, mais
#       AUTORISÉS dans les sources du blog — « nous utilisons Proxmox » est un
#       argument de compétence, pas une fuite.
#
# Périmètre : tous les fichiers suivis par git, ce script s'excluant lui-même
# puisqu'il contient par nature les motifs qu'il traque.
#
# Sortie : 0 si propre, 1 au premier motif trouvé. Arrêt mécanique, jamais
# « afficher un avertissement puis continuer ».
#
# Variables d'environnement :
#   RELEASE=1  → la présence d'un placeholder {{...}} devient bloquante.
# =============================================================================
set -euo pipefail

cd "$(dirname "$0")/.."
SELF="scripts/check-leaks.sh"
FAILED=0

# La famille « produits » est une contrainte ÉDITORIALE sur les pages servies de
# la vitrine, pas une règle de sécurité. Elle ne s'applique donc qu'à public/ :
# ni aux sources du blog (D-site-10), ni à la documentation du dépôt, qui doit
# pouvoir nommer les technologies dont elle parle — y compris cette règle.
VITRINE_PREFIX='^public/'

mapfile -t ALL_FILES < <(git ls-files | grep -vx "$SELF" || true)
if [ "${#ALL_FILES[@]}" -eq 0 ]; then
  echo "ABORT: aucun fichier suivi par git à analyser." >&2
  exit 1
fi
mapfile -t VITRINE_FILES < <(printf '%s\n' "${ALL_FILES[@]}" | grep -E "$VITRINE_PREFIX" || true)
PUBLIC_FILES=("${VITRINE_FILES[@]}")

# scan <libellé> <regex étendue> [périmètre: all|vitrine]
scan() {
  local label="$1" pattern="$2" scope="${3:-all}" hits
  local -n files=ALL_FILES
  if [ "$scope" = "vitrine" ]; then
    local -n files=VITRINE_FILES
  fi
  [ "${#files[@]}" -eq 0 ] && return 0
  hits=$(grep -nEIi -- "$pattern" "${files[@]}" 2>/dev/null || true)
  if [ -n "$hits" ]; then
    echo "ABORT: $label" >&2
    echo "$hits" | sed 's/^/    /' >&2
    FAILED=1
  fi
}

# --- 1. Adresses IP internes / d'infrastructure ------------------------------
scan "adresse IP privée (RFC1918)" \
  '\b(192\.168|10)\.[0-9]{1,3}\.[0-9]{1,3}(\.[0-9]{1,3})?\b|\b172\.(1[6-9]|2[0-9]|3[01])\.[0-9]{1,3}\.[0-9]{1,3}\b'
scan "adresse IP d'edge de l'infrastructure" '\b94\.130\.78\.137\b'

# --- 2. Identifiants de machines virtuelles et de conteneurs -----------------
# Trois formes, toutes contextuelles. Les bornes évitent d'attraper une année :
# les commandes Proxmox ne sont jamais suivies d'un millésime.
#   a) forme accolée      : « LXC 226 », « CT-232 », « vmid140 »
#   b) forme commande     : « pct exec 225 », « vzdump 216 », « qm start 140 »
#   c) forme affectation  : « GPU_LXC="225 226" », « ALL_GUESTS="…" », « for VMID in 217 »
scan "identifiant de VM/conteneur, forme accolée" \
  '\b(ct|lxc|vmid|vm|pct|qm|node)[ _-]?[0-9]{2,4}\b'
scan "identifiant de VM/conteneur, forme commande" \
  '\b(pct|qm|vzdump)\s+([a-z-]+\s+)?[0-9]{2,4}\b'
scan "identifiant de VM/conteneur, forme affectation" \
  '(vmid|lxc|guests?)[a-z_]*\s*(=|in)\s*"?[0-9]{2,4}\b'

# --- 3. Noms d'hôtes et de services internes ---------------------------------
scan "nom d'hôte ou de service interne" \
  '\b(titan|render|gateway01|caddy01|bastion|cortex|huly|kuma|uptime-kuma|vaultwarden|litellm|searxng|qdrant|adguard|technitium|wireguard)\b'

# « storage » est à la fois un hostname de la flotte et un mot courant, présent
# dans des options de commande parfaitement banales (« --storage local-lvm »).
# Le motif ne se déclenche donc que sur les formes où il désigne une machine.
scan "nom d'hôte interne « storage » en position de machine" \
  '\b(ssh|scp|rsync|host|hostname)\s+storage\b|@storage\b|\bstorage\.(lab|hkconseils|local)\b|\bstorage:[/~]'

scan "sous-domaine interne ou de client" \
  '(lab\.hkconseils\.fr|medicapsante|devcapiliblab|openwebchat|hpmini)'

# --- 4. Noms de clients et de projets sous NDA -------------------------------
scan "nom de client ou de projet confidentiel" \
  '\b(capilib|medicap|tryon|openexam|sila)\b'

# --- 5. Inventaire matériel et produits d'infrastructure ---------------------
# D-site-10 : pages servies de la vitrine seulement. Les articles du blog parlent
# librement de Proxmox, ZFS ou d'un modèle de GPU, c'est leur sujet ; la
# documentation du dépôt doit pouvoir énoncer la règle sans la déclencher.
scan "modèle de matériel ou produit d'infrastructure (vitrine)" \
  '\b(rtx ?[0-9]{4}|a4000|a5000|l40s?|epyc|threadripper|proxmox|pve|vzdump|ceph|zfs|truenas|ipmi)\b' \
  vitrine

# --- 6. Aucune ressource externe (AC8, §1 « no CDN ») ------------------------
# Vise les ressources chargées par le navigateur, pas les liens de navigation.
scan "ressource chargée depuis un domaine externe" \
  'src="https?://|url\( *["'"'"']?https?://|@import[^;]*https?://|rel="(stylesheet|preload)"[^>]*href="https?://'

# --- 7. Placeholders non résolus ---------------------------------------------
# Uniquement sur le contenu déployé : README.md et REPORT.md citent
# légitimement les placeholders restant à fournir.
PLACEHOLDERS=""
if [ "${#PUBLIC_FILES[@]}" -gt 0 ]; then
  PLACEHOLDERS=$(grep -nEIo '\{\{[A-Z0-9_]+\}\}' "${PUBLIC_FILES[@]}" 2>/dev/null || true)
fi
if [ -n "$PLACEHOLDERS" ]; then
  if [ "${RELEASE:-0}" = "1" ]; then
    echo "ABORT: placeholder non résolu alors que RELEASE=1" >&2
    echo "$PLACEHOLDERS" | sed 's/^/    /' >&2
    FAILED=1
  else
    echo "AVERTISSEMENT: placeholder(s) non résolu(s) — bloquant si RELEASE=1" >&2
    echo "$PLACEHOLDERS" | sed 's/^/    /' >&2
  fi
fi

if [ "$FAILED" -ne 0 ]; then
  echo "" >&2
  echo "check-leaks: ÉCHEC — le contenu ne peut pas être publié en l'état." >&2
  exit 1
fi

echo "check-leaks: OK — ${#ALL_FILES[@]} fichiers analysés, dont ${#VITRINE_FILES[@]} soumis à la famille « produits » ; aucun motif interdit."
