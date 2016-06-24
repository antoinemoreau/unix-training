#! /bin/bash

. ./treasure-setup.sh
. ./i18n-lib.sh
. ./rotlib.sh

gettext "Bravo !

La solution la plus simple était :

  ./decoder.py < etape-E5.txt | ./decoder_bis.py

Attention il faut bien distinguer les redirections vers/depuis les
fichiers (< et >) et les pipes (|). Si nous avions écrit par exemple

  ./decoder.py < etape-E5.txt > ./decoder_bis.py

nous aurions envoyé la sortie de decoder.py vers le *fichier*
decoder_bis.py au lieu d'exécuter la commande decoder_bis.py. Ça
n'aurait bien sûr pas marché, et en plus nous aurions écrasé le
fichier decoder_bis.py !

L'etape suivante est accessible depuis votre machine de travail, dans
le repertoire

  \${maindir_tilde}/kmcvoaue/\${step}-E6/

Les instructions sont dans le seul fichier de ce repertoire (et de ses
sous-répertoires) dont le nom se termine par .txt.
" | envsubst | tr "[abcdef1234567890xyzt]" "[1234567890xyztabcdef]" | \
    decalepipe > $(gettext etape)-E3/$(gettext etape)-E5.txt
