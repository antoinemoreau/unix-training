#! /bin/bash

. ./treasure-setup.sh
. ./i18n-lib.sh
. ./adalib.sh
. ./c-lib.sh
. ./odtlib.sh

HUNT_DIR=$(pwd)

header=$(gettext "Fichier source pour l'etape D2.
Le programme est coupé en 3 morceaux.
Assemblez-les puis compilez le programme.
")

# Pas d'accent sur la fin du texte, le copier-coller ne marcherait pas
# forcément.
body=$(gettext "Visiblement, le copier-coller a marché !

La suite se trouve ici :

\$web_url/4ba3/text-editor-fr.php

Ouvrez cette page dans votre navigateur et laissez-vous guider.
" | envsubst)

# Ada
(
    echo "$header" | ada_comment_out

    adawithuse

    gettext "procedure Etape_D2 is"
    echo
    adadecode
    echo "begin"

    echo "$body" | ada_obfuscate

    gettext "end Etape_D2;"
    echo

) > $(gettext etape)_d2.adb

gettext "etape_d2.adb genere" >&2
echo >&2

sed -ne '1,8p' $(gettext etape)_d2.adb | txt2odt $(gettext etape)_d2-1-ada.odt

sed -ne '9,16p' $(gettext etape)_d2.adb > $(gettext etape)_d2-2-ada.txt

sed -ne '17,$p' $(gettext etape)_d2.adb > $(gettext etape)_d2-3-ada.txt

# C
(
    echo "$header" | c_comment_out

    c_dprint_header

    echo "$body" | c_obfuscate_full
) > $(gettext etape)_d2.c

gettext "etape_d2.c genere" >&2
echo >&2

sed -ne '1,19p' $(gettext etape)_d2.c | txt2odt $(gettext etape)_d2-1-c.odt

sed -ne '20,39p' $(gettext etape)_d2.c > $(gettext etape)_d2-2-c.txt

sed -ne '40,$p' $(gettext etape)_d2.c > $(gettext etape)_d2-3-c.txt
