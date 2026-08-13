#!/usr/bin/env bash
# =============================================================================
# check-leaks.sh — porte AC5 : rien de l'infrastructure interne, aucun nom de
# client, aucun appel externe ne doit se retrouver dans le contenu publié.
#
# Décisions appliquées (D1 + D2, validées le 2026-08-13) :
#   · pas de regex numérique nue pour les VMID — détection PAR CONTEXTE, car un
#     motif [0-9]{3} déclencherait sur le contenu approuvé (1 485, 100/100,
#     SIREN 100 332 816…) et la porte finirait désactivée ;
#   · IP privées détectées en quadruplet complet, pour la même raison ;
#   · agrégats de capacité autorisés (« 4 GPU », « 24 Go »), noms de modèles et
#     de produits d'infrastructure interdits ;
#   · périmètre = tous les fichiers suivis par git, pas seulement public/,
#     puisque l'interdiction porte aussi sur le code et les commentaires ;
#   · ce script s'exclut lui-même du scan : il contient par nature les motifs.
#
# Sortie : 0 si propre, 1 au premier motif trouvé. Arrêt mécanique, jamais
# « afficher un avertissement puis continuer ».
#
# Variable d'environnement :
#   RELEASE=1  → la présence d'un placeholder {{...}} devient bloquante.
# =============================================================================
set -euo pipefail

cd "$(dirname "$0")/.."
SELF="scripts/check-leaks.sh"
FAILED=0

# Fichiers suivis par git, sauf ce script lui-même.
mapfile -t FILES < <(git ls-files | grep -vx "$SELF" || true)
if [ "${#FILES[@]}" -eq 0 ]; then
  echo "ABORT: aucun fichier suivi par git à analyser." >&2
  exit 1
fi

scan() { # scan <libellé> <regex étendue>
  local label="$1" pattern="$2" hits
  hits=$(grep -nEIi -- "$pattern" "${FILES[@]}" 2>/dev/null || true)
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

# --- 2. Identifiants de machines virtuelles / conteneurs ---------------------
# Détection contextuelle : le préfixe rend le nombre identifiable comme VMID.
scan "identifiant de VM/conteneur (VMID)" \
  '\b(ct|lxc|vmid|vm|pct|qm|node)[ _-]?[0-9]{2,4}\b'

# --- 3. Noms d'hôtes et de services internes ---------------------------------
scan "nom d'hôte ou de service interne" \
  '\b(titan|render|storage|gateway01|caddy01|bastion|cortex|huly|kuma|uptime-kuma|vaultwarden|litellm|searxng|qdrant|adguard|technitium|wireguard)\b'
scan "sous-domaine interne ou de client" \
  '(lab\.hkconseils\.fr|medicapsante|devcapiliblab|openwebchat|hpmini)'

# --- 4. Noms de clients et de projets sous NDA -------------------------------
scan "nom de client ou de projet confidentiel" \
  '\b(capilib|medicap|tryon|openexam|sila)\b'

# --- 5. Inventaire matériel et produits d'infrastructure (D2) ----------------
# Les agrégats (« 4 GPU », « 24 Go », « 48 Go ») restent autorisés : ils
# décrivent une capacité, pas une topologie.
scan "modèle de matériel ou produit d'infrastructure" \
  '\b(rtx ?[0-9]{4}|a4000|a5000|l40s?|epyc|threadripper|proxmox|pve|vzdump|ceph|zfs|truenas|ipmi)\b'

# --- 6. Aucune ressource externe (AC8, §1 « no CDN ») ------------------------
# Vise les ressources chargées par le navigateur (src, url(), @import,
# feuilles de style) — pas les liens de navigation en <a href>.
scan "ressource chargée depuis un domaine externe" \
  'src="https?://|url\( *["'"'"']?https?://|@import[^;]*https?://|rel="(stylesheet|preload)"[^>]*href="https?://'

# --- 7. Placeholders non résolus ---------------------------------------------
# Uniquement sur le contenu déployé : README.md et REPORT.md citent légitimement
# les placeholders restant à fournir, et ne doivent pas bloquer la publication.
mapfile -t PUBLIC_FILES < <(printf '%s\n' "${FILES[@]}" | grep '^public/' || true)
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

echo "check-leaks: OK — ${#FILES[@]} fichiers analysés, aucun motif interdit."
