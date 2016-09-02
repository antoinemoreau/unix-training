#!/bin/sh

. ./treasure-setup.sh
. ./spy-lib.sh
. ./i18n-lib.sh

dest=$(gettext etape)-B2.sh

# This may be too easy to "decode", but beeing able to do that may
# also indicate that the current exercice is not useful..

exec > "$dest"

printf "%s\n" '#!/bin/bash

# RedHat bug with base64 -d => use -i as a workaround
# https://bugzilla.redhat.com/show_bug.cgi?id=719317
bash -c "$(base64 -di <<EOF'

# Encode script (note we should take care that it does not generate any dollar sign).
base64 <<EOF
#!/bin/bash

p=''
cat << NESTEDEOF
$(gettext "Entrez ci-dessous le mot de passe.

Ce mot de passe vous est donné dans le guide « Initiation à Unix,
L'environnement de travail à l'Ensimag », chapitre 4. Si vous n'avez
pas encore lu le guide jusque là, il est temps d'avancer sur la
lecture de ce document, vous continuerez le jeu de piste après.
")
NESTEDEOF
echo

while [ "\$p" != jeu2piste ]; do
    printf '%s' "$(gettext "Mot de passe : ")"
    read p
    if [ -z "\$p" ]; then
        echo "$(gettext "Au revoir
")"
        exit
    fi
done

echo

cat << NESTEDEOF
$(gettext "Très bien.

L'etape suivante se trouve dans le fichier.
\$web_url/etape-C1.tex

Cette fois-ci, c'est un fichier LaTeX. LaTeX est un format de fichier
qui permet de faire de jolis documents avec une mise en page
automatique. Vous pouvez compiler ce fichier avec la commande

  pdflatex etape-C1.tex

pour obtenir un fichier PDF, que vous ouvrirez ensuite avec le
logiciel approprie.
" | envsubst)
NESTEDEOF
EOF

echo 'EOF'
echo ')"'

chmod +x "$dest"
