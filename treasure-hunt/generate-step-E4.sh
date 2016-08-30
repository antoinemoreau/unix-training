#! /bin/bash

. ./treasure-setup.sh
. ./i18n-lib.sh
. ./rotlib.sh

mkdir -p $(gettext etape)-E3/

gettext "Bien, vous avez reussi a decoder le message.

La solution la plus élégante était d'utiliser une redirection, comme
ceci :

  ./decoder.py < etape-E4.txt

Si on veut sauvegarder le résultat, on peut aussi écrire

  ./decoder.py < etape-E4.txt > etape-E4-decodee.txt

puis regarder le contenu du fichier etape-E4-decodee.txt.

(Envelez les '.py' dans les commandes ci-dessus si vous avez utilisé
un langage autre que Python bien sûr).

Pour l'etape suivante, le message se trouve dans etape-E5.txt, mais
il est doublement code : pour le decoder, il va falloir passer dans
deux filtres differents.

Le deuxième filtre s'appelle \"decoder_bis\", il va falloir effectuer
les mêmes opérations que précédemment (le rendre exécutable pour
le fichier python ou le compiler pour les versions C et Ada).

Vous devriez, en une (seule) ligne de commande, executer quelque chose
comme cela :

fichier ----> decoder.py -----> decoder_bis.py ----> affichage

(en utilisant la notion de \"pipe\").
" | decalepipe > $(gettext etape)-E3/$(gettext etape)-E4.txt
