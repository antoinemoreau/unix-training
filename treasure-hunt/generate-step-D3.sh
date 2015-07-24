#!/bin/bash

. ./treasure-setup.sh
. ./spy-lib.sh
. ./i18n-lib.sh
. ./adalib.sh
. ./c-lib.sh

file=text-editor-$(gettext fr).php

echo '<?php' >"$file"

title=$(gettext "Etape D3: édition de texte")
instructions=$(gettext "Ci-dessous un programme %s à compiler (<a href=\"?language=%s\">Cliquez ici pour une version en %s</a>),
avec plusieurs problèmes :
<ul>
<li>L'ensemble du programme est commenté, il faudra donc supprimer les <code>%s</code> en début de ligne</li>
<li>L'auteur a utilisé parfois des crochets [] au lieu des parenthèses ()</li>
<li>Il reste quelques erreurs de syntaxes</li>
</ul>
La mauvaise nouvelle, c'est que ce programme n'est valide que pendant %d secondes, il va donc falloir être rapide pour faire toutes ces corrections. Préparez-vous, et rechargez la page pour relancer le compte à rebours.
<br />
Si ce n'est pas déjà fait, lisez jusqu'au bout la page
<a href=\"http://ensiwiki.ensimag.fr/index.php/Premiers_pas_avec_Emacs_et_Ada\">Premiers pas avec Emacs et Ada</a>
sur EnsiWiki, elle contient des conseils pour aller plus vite.
")
the_answer_is=$(gettext "La réponse est :")
invalid_answer=$(gettext 'Réponse incorrecte : "%s" (en %01.1f secondes).')
you_took=$(gettext "Vous avez pris %01.1f secondes, et il fallait terminer en moins de %d, désolé. Je génère un nouveau programme.")
correctly_compiled=$(gettext "Programme compilé correctement en %01.1f secondes.")
next_step=$(gettext "L'étape suivante se trouve dans le fichier

\$maindir_tilde/oaue/etape-E1

La personne qui a créé ce fichier l'a nommé étrangement :
il n'a pas mis d'extension (i.e. le nom de fichier ne se 
termine pas par .quelquechose). Pour savoir de quel type
de fichier il s'agit, utilisez la commande 'file', et
utilisez ensuite l'outil adapté pour l'ouvrir.

Selon votre configuration, vous aurez peut-être besoin de renommer (ou
copier) le fichier pour lui donner l'extension habituelle pour ce type
de fichier.
" | envsubst)
useless_comment=$(gettext "Ceci est un vrai commentaire inutile.")
enter_value_here=$(gettext "Entrez la sortie du programme compilé ici :")

for v in title instructions the_answer_is invalid_answer \
         you_took correctly_compiled \
         next_step useless_comment enter_value_here
do
    value=$(eval "printf '%s\n\n' \"\$$v\"" | sed "s/'/\\\\'/g")
    printf "\$%s = '%s';\n" "$v" "$value" >> "$file"
done

cat >>"$file" <<EOF
\$noise_ada = array();
\$noise_ada[] = '$(Noise | tr '()' '[]')';
\$noise_ada[] = '$(Noise)';
\$noise_ada[] = '$(Noise)';
\$noise_ada[] = '$(Noise)';
\$noise_ada[] = '$(Noise)';
\$noise_c = array();
\$noise_c[] = '$(c_noise | tr '()' '[]')';
\$noise_c[] = '$(c_noise)';
\$noise_c[] = '$(c_noise)';
\$noise_c[] = '$(c_noise)';
\$noise_c[] = '$(c_noise)';
?>
EOF

cat text-editor-template.php >>"$file"

chmod +x text-editor-$(gettext fr).php
