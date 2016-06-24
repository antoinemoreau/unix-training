#! /bin/bash

. ./treasure-setup.sh
. ./spy-lib.sh
. ./rotlib.sh
. ./i18n-lib.sh

exec > $(gettext etape)-G2.sh

printf "%s\n\n" '#!/bin/bash'

cat ./rotlib-decode.sh

cat <<EOF
die_rotpipe () { echo "\$@" | unrotpipe; exit 1; }
[ -z "\$SSH_CLIENT" ] && die_rotpipe "$(gettext "Il semble que vous ne soyez pas connectes à la machine via SSH.

Je refuse de m'exécuter dans ces conditions, désolé.
Merci de vous connecter à cette machine via SSH, et je
vous donnerai la solution.

Si cette étape se trouve sur la même machine que votre machine de
travail habituel, vous pouvez utiliser un PC individuel ou votre
machine personnelle pour réaliser cette étape.
" | rotpipe)"
EOF

printf "%s" '
echo '\"

gettext "Bien.

L'étape suivante est très similaire, c'est aussi un exécutable à
lancer sur une machine distante. L'exécutable se trouve sur le
serveur \${auxiliarymachine}, à l'emplacement :

  ~\${auxiliary_user}/jeu-de-piste/FqM6IhHP/etape-G3.sh

La commande en question utilise un affichage graphique, donc vous
risquez d'avoir besoin de l'option -X de la commande ssh.
" | envsubst | rotpipe

printf "%s" \"'| unrotpipe'

chmod +x $(gettext etape)-G2.sh
