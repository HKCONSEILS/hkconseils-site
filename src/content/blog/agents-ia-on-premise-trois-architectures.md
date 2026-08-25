---
title: "Agents IA on-premise : trois architectures"
description: "Trois runtimes d'agents évalués sur le même matériel et le même modèle, avec des seuils écrits avant la mesure. Ce qu'ils protègent, ce qu'ils laissent passer, ce qu'ils coûtent, et pourquoi le choix ne se joue pas là où on l'attend."
pubDate: 2026-08-27
tags: ["agents", "architecture", "on-premise", "comparatif"]
---

Choisir un runtime d'agent se réduit rarement à comparer des fonctionnalités. Les trois que nous exploitons ou avons évalués savent tous répondre, appeler des outils, mémoriser et planifier. Ce qui les sépare est ailleurs : dans ce qu'ils font sans qu'on le leur demande, dans ce qu'ils laissent accessible à l'agent, et dans ce qu'on peut relire avant que ça s'applique. Cet article met les trois côte à côte, avec les mesures et avec leurs limites.

*Comparaison établie le 24 août 2026 à partir de deux POC menés les 22, 23 et 24 août sur le même matériel et le même modèle, et de l'exploitation courante de notre propre plateforme. Les chiffres cités sont ceux relevés pendant ces opérations.*

## Trois positions, pas trois concurrents

**OpenClaw (notre plateforme interne)** est la plateforme que nous construisons et exploitons. Elle est planifiée en sept phases, dont deux sont livrées, et elle porte aujourd'hui deux blocs matures : un agent de veille en service continu, et un pipeline de décision encadré par des règles codées hors de portée du modèle. Son détail est dans [l'article qui lui est consacré](/blog/openclaw-plateforme-multi-agents-lecons/).

**Hermes (agent conversationnel Python)** a été évalué comme candidat pour les usages de messagerie. Neuf critères, huit tenus. Son POC a surtout mis au jour trois comportements non annoncés, décrits dans [son article dédié](/blog/hermes-poc-agent-ce-qui-nest-pas-annonce/).

**IronClaw (runtime Rust)** a été évalué comme option pour les contextes les plus exigeants en confinement. Onze critères, deux échecs assumés, et un mode de protection des secrets que les deux autres n'atteignent pas. Son article est [ici](/blog/ironclaw-secret-absent-pas-refuse/).

Une précaution avant de comparer, parce qu'elle change la lecture du tableau : **notre plateforme interne n'a pas été passée au même banc**. Elle est en exploitation, pas en évaluation. Les cases vides de sa colonne signifient « non mesuré dans ce cadre », jamais « absent ».

## Le tableau

<div style="overflow-x:auto">

| | OpenClaw (plateforme interne) | Hermes (agent Python) | IronClaw (runtime Rust) |
|---|---|---|---|
| Mécanisme d'identité | fichier unique sur disque | fichier unique posé par l'exploitant | **quatre fichiers natifs**, injectés à chaque tour |
| Qui écrit l'identité | l'exploitant | l'exploitant | **l'agent lui-même**, sous profil base de données |
| Identité relisible avant application | oui | oui | **non**, elle vit en base |
| Restriction d'outillage | native, par canal | native, outils non chargés | **native et plus fine**, par capacité, effet mesuré |
| Secrets accessibles à l'agent | non mesuré | non mesuré | **non, absence structurelle** |
| Terminal accessible à l'agent | non mesuré | **oui en ligne de commande**, prouvé par une commande exécutée | non par défaut, l'outil d'écriture étant désactivé |
| Cloisonnement réseau | liste blanche de sortie | liste blanche de sortie par compte | **deux couches**, applicative et pare-feu, chacune prouvée seule |
| Protection contre les requêtes détournées | non mesuré | non mesuré | **oui**, y compris après résolution de nom |
| Bac à sable d'outils | non mesuré | non mesuré | **WebAssembly**, mémoire, temps et accès |
| Installation au démarrage | aucune | **deux paquets, à chaque lancement** | aucune |
| Empreinte mémoire | non mesuré | 139 Mo | 193 Mo, plus 102 Mo de base |
| Pic processeur en génération | non mesuré | **209 %** d'un cœur | **18 %** d'un cœur |
| Latence par tour | non mesuré | 14,0 s à froid, 7,4 s à chaud | **environ 22 s**, plate |

</div>

### Une réserve de méthode, à ne pas dissimuler

Les deux POC n'ont pas emprunté le même canal : l'agent Python a été éprouvé sur une messagerie, le runtime Rust sur son interface web. Les mesures de **charge** restent directement comparables, puisque le matériel, le modèle et le proxy de modèles étaient identiques. Les mesures d'**adhérence aux consignes** le sont moins : le canal influe sur le formatage attendu et sur la façon dont l'agent se présente.

Le dire est plus utile que de présenter douze lignes homogènes dont deux ne le sont pas.

## Ce que la comparaison apprend vraiment

### Le confinement et la gouvernance ne progressent pas ensemble

C'est le résultat le plus contre-intuitif. Le runtime le plus solide sur le confinement est le plus faible sur la gouvernance de l'identité.

D'un côté : secrets structurellement absents du processus d'outillage, double couche réseau, bac à sable éprouvé par trois témoins inverses, aucune installation, aucune télémétrie. De l'autre : une identité qui vit dans une base de données, écrite par l'agent lui-même, sans voie opérateur, donc **ni versionnable ni relisible avant application**.

Les deux autres font l'inverse : une identité qui est un fichier, donc revue, datée, comparable, et un confinement plus perméable.

Il n'y a pas de bon choix dans l'absolu. Il y a une question à se poser : dans votre contexte, le risque dominant est-il qu'un agent lise ce qu'il ne devrait pas, ou qu'une politique change sans que personne s'en aperçoive.

<figure>
<svg viewBox="0 0 820 470" role="img" aria-label="Matrice à deux axes. L'axe horizontal mesure la force du confinement, de faible à forte. L'axe vertical mesure la gouvernance de l'identité de l'agent, c'est-à-dire la possibilité de la relire et de la versionner avant qu'elle s'applique. IronClaw se place en bas à droite : confinement fort, gouvernance faible, son identité vivant dans une base et étant écrite par l'agent lui-même. Hermes se place en haut à gauche : gouvernance forte car l'identité est un fichier posé par l'exploitant, confinement plus perméable. OpenClaw se place en haut, avec une gouvernance forte, mais sa position sur l'axe du confinement n'est pas mesurée : elle est représentée par une bande en pointillés et non par un point." xmlns="http://www.w3.org/2000/svg" style="width:100%;height:auto;font-family:var(--font-sans,sans-serif)">
  <rect x="0" y="0" width="820" height="470" fill="var(--color-surface-sunken,#fafbfc)" rx="10"/>
  <text x="32" y="42" font-size="15" font-weight="700" fill="var(--color-fg,#071b3b)">Confinement et gouvernance ne progressent pas ensemble</text>
  <text x="32" y="64" font-size="12" fill="var(--color-fg-muted,#6b7280)">Le plus solide sur le confinement est le plus faible sur la gouvernance de l'identité.</text>
  <rect x="120" y="90" width="600" height="300" rx="8" fill="var(--color-surface,#fff)" stroke="var(--color-border,#e5e7eb)"/>
  <line x1="420" y1="90" x2="420" y2="390" stroke="var(--color-border,#e5e7eb)" stroke-dasharray="4 4"/>
  <line x1="120" y1="240" x2="720" y2="240" stroke="var(--color-border,#e5e7eb)" stroke-dasharray="4 4"/>
  <text x="420" y="416" font-size="12.5" font-weight="700" text-anchor="middle" fill="var(--color-fg,#071b3b)">Force du confinement</text>
  <text x="140" y="416" font-size="11" fill="var(--color-fg-muted,#6b7280)">plus faible</text>
  <text x="700" y="416" font-size="11" text-anchor="end" fill="var(--color-fg-muted,#6b7280)">plus forte</text>
  <text x="0" y="0" font-size="12.5" font-weight="700" text-anchor="middle" fill="var(--color-fg,#071b3b)" transform="translate(64,240) rotate(-90)">Gouvernance de l'identité</text>
  <text x="0" y="0" font-size="11" text-anchor="middle" fill="var(--color-fg-muted,#6b7280)" transform="translate(100,130) rotate(-90)">relisible</text>
  <text x="0" y="0" font-size="11" text-anchor="middle" fill="var(--color-fg-muted,#6b7280)" transform="translate(100,352) rotate(-90)">non relisible</text>
  <rect x="150" y="128" width="252" height="18" rx="9" fill="none" stroke="var(--color-fg-muted,#6b7280)" stroke-width="1.5" stroke-dasharray="5 4"/>
  <circle cx="182" cy="137" r="9" fill="none" stroke="var(--color-fg-muted,#6b7280)" stroke-width="2"/>
  <text x="150" y="118" font-size="12.5" font-weight="700" fill="var(--color-fg,#071b3b)">OpenClaw</text>
  <text x="412" y="142" font-size="10.5" fill="var(--color-fg-muted,#6b7280)">confinement non mesuré au même banc</text>
  <circle cx="248" cy="192" r="11" fill="var(--color-fg,#071b3b)"/>
  <text x="268" y="190" font-size="12.5" font-weight="700" fill="var(--color-fg,#071b3b)">Hermes</text>
  <text x="268" y="207" font-size="10.5" fill="var(--color-fg-muted,#6b7280)">identité posée par l'exploitant, terminal accessible en CLI</text>
  <circle cx="628" cy="330" r="11" fill="var(--color-accent,#005ffa)"/>
  <text x="608" y="326" font-size="12.5" font-weight="700" text-anchor="end" fill="var(--color-accent,#005ffa)">IronClaw</text>
  <text x="608" y="343" font-size="10.5" text-anchor="end" fill="var(--color-fg-muted,#6b7280)">secrets absents, bac à sable, deux couches réseau</text>
  <text x="608" y="358" font-size="10.5" text-anchor="end" fill="var(--color-fg-muted,#6b7280)">identité écrite par l'agent, dans une base</text>
  <rect x="32" y="432" width="756" height="24" rx="6" fill="var(--color-surface,#fff)" stroke="var(--color-border,#e5e7eb)"/>
  <circle cx="52" cy="444" r="6" fill="var(--color-fg,#071b3b)"/>
  <text x="66" y="448" font-size="11" fill="var(--color-fg,#071b3b)">position mesurée sur les deux axes</text>
  <circle cx="330" cy="444" r="6" fill="none" stroke="var(--color-fg-muted,#6b7280)" stroke-width="2"/>
  <text x="344" y="448" font-size="11" fill="var(--color-fg-muted,#6b7280)">marqueur creux et bande en pointillés : axe non mesuré, aucune position affirmée</text>
</svg>
<figcaption>La question à se poser n'est pas laquelle est la meilleure, mais lequel des deux risques domine dans votre contexte : qu'un agent lise ce qu'il ne devrait pas, ou qu'une politique change sans que personne s'en aperçoive.</figcaption>
</figure>

### Un défaut d'usine est une décision qu'on prend pour vous

Trois exemples, un par produit, tous découverts par la mesure et non par la documentation.

Le runtime Rust expose cinquante et une portes d'approbation, toutes correctement conçues, et un réglage global d'approbation automatique **actif à l'installation** qui les neutralise ensemble.

L'agent Python demande **trois** réglages pour empêcher la création automatique de compétences là où la documentation en annonce un ; les deux autres sont actifs par défaut et absents de la configuration livrée.

Notre propre plateforme n'a pas échappé à la règle : son composant de contrôle appliquait ses règles correctement mais **ne les journalisait pas**, ce qui rendait invérifiable une affirmation que nous portions dans nos documents. Nous l'avons retirée, puis instrumentée.

Trois produits, un même schéma : **ce qui n'est pas explicitement fermé est ouvert, et rien ne vous le signale**.

### La panne silencieuse est le mode de défaillance dominant

Sur les trois plateformes, les défauts les plus coûteux partagent une propriété : le système fonctionne, ne signale rien, et le résultat est faux.

Un jeton de veille expiré produit exactement ce que produit un service en bonne santé, à savoir aucune alerte. Un contrôle sans journal fonctionne peut-être parfaitement, mais rien ne permet de l'affirmer. Une passerelle en panne pendant que la ligne de commande répond parfaitement laisse croire à un produit fonctionnel. Des fichiers d'identité placés au mauvais endroit ne provoquent aucune erreur : ils sont simplement retrouvés par recherche sémantique au lieu d'être injectés, ce qui donne une adhérence intermittente.

La conséquence pratique est une règle de conception, pas une bonne intention : **tout contrôle doit produire une trace, et tout contrôle qui ne produit rien doit être considéré comme absent** jusqu'à preuve du contraire.

### Le contrôle strict est aussi un instrument de mesure

Le comportement le plus important relevé pendant ces POC n'était pas cherché. C'est une liste blanche de sortie réseau qui l'a rendu visible : sans elle, l'installation de paquets à chaque démarrage aurait réussi silencieusement, et personne n'aurait su qu'un agent tirait du code à chaque réveil.

Un environnement contraint ne sert pas seulement à empêcher. Il sert à rendre bruyant ce qui, ailleurs, passe inaperçu.

## Comment nous tranchons

Sans transformer cela en recommandation universelle, voici la logique que nous appliquons.

Pour un usage **conversationnel interne**, où l'enjeu est la disponibilité et le confort, l'agent Python est le plus rapide à chaud et le plus léger en mémoire, à condition de neutraliser explicitement l'installation au démarrage et les trois chemins de création de compétences.

Pour un contexte **exigeant en confinement**, où l'on doit pouvoir démontrer et pas seulement affirmer, le runtime Rust est le seul des trois à produire une absence plutôt qu'un refus, et le seul à faire tenir un bac à sable sous témoin inverse. Au prix d'une latence qui interdit l'échange interactif, et d'une gouvernance d'identité à compenser par une procédure.

Pour l'**orchestration métier** et tout ce qui doit être audité, notre plateforme interne reste le socle, parce que ses règles sont dans du code et non dans une invite, et parce qu'elles sont désormais tracées.

Le dernier mot revient à la même idée que les trois articles partagent : **un contrôle vaut par ce qu'il exerce, pas par ce qu'il affiche**.
