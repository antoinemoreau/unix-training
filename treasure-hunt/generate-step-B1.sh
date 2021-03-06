#! /bin/bash

. ./treasure-setup.sh
. ./c-lib.sh
. ./python-lib.sh
. ./adalib.sh
. ./i18n-lib.sh


body=$(gettext "Bonjour,

Si vous lisez ceci, c'est que vous avez reussi l'etape B1
du jeu de piste.

L'étape suivante est un script à exécuter, il s'appelle etape-B2.sh et
se trouve dans le même répertoire que les fichiers de l'étape B1 que
vous venez de terminer. Exécutez ce script.

" | envsubst)

(
gettext "Fichier source pour l'etape B1.
Compilez-le et executez-le pour continuer.

" | c_comment_out

c_dprint_header
echo "$body" | c_obfuscate_full

) > $(gettext etape)_b1.c

echo $(gettext etape)_b1.c "generated" >&2


(
gettext "Fichier source pour l'etape B1.
Ce programme doit etre dans un fichier etape_b1.adb
Compilez-le et executez-le pour continuer.

" | ada_comment_out
adawithuse
gettext "procedure Etape_B1 is"
adadecode
echo "begin"
echo "$body" | ada_obfuscate
echo "end;"
) > $(gettext etape)_b1.adb

echo $(gettext etape)_b1.adb "generated" >&2

(
    python_shebang_docstring $(gettext "Fichier source pour l'étape B1.
Ce programme doit être dans un fichier avec l'extension .py.
Exécutez-le avec la commande python3 pour continuer.
")

    echo "$body" | python_obfuscate_text

) > $(gettext etape)_b1.py

chmod +x $(gettext etape)_b1.py

echo $(gettext etape)_b1.py "generated" >&2

