#!/bin/bash

. ./treasure-setup.sh
. ./spy-lib.sh
. ./i18n-lib.sh
. ./adalib.sh
. ./c-lib.sh
. ./python-lib.sh

file=text-editor-$(gettext fr).php

echo '<?php' >"$file"

title=$(gettext "Etape D3: édition de texte")
instructions=$(gettext "Ci-dessous un programme %s à exécuter (autres versions à compiler : %s),
avec plusieurs problèmes :
<ul>
<li>L'ensemble du programme est commenté, il faudra donc supprimer les <code>%s</code> en début de ligne</li>
<li>L'auteur a utilisé des crochets [] au lieu des parenthèses (). Il n'y a aucun [] dans le code valide.</li>
<li>Il reste quelques erreurs de syntaxes</li>
</ul>
La mauvaise nouvelle, c'est que ce programme n'est valide que pendant
%d secondes, il va donc falloir être rapide pour faire toutes ces
corrections. Préparez-vous, et générez un nouveau programme pour
relancer le compte à rebours.
<br />
Si ce n'est pas déjà fait, lisez jusqu'au bout la page
%s, elle contient des conseils pour aller plus vite.
")
the_answer_is=$(gettext "La réponse est :")
invalid_answer=$(gettext 'Réponse incorrecte : "%s" (en %01.1f secondes).')
you_took=$(gettext "Vous avez pris %01.1f secondes, et il fallait terminer en moins de %d, désolé. Je génère un nouveau programme.")
correctly_compiled=$(gettext "Programme exécuté correctement en %01.1f secondes.")
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
enter_value_here=$(gettext "Entrez la sortie de l'exécution du programme ici :")
click_here_to_reset=$(gettext "Cliquez ici pour générer un nouveau programme :")
remaining_text=$(gettext "Il reste %d secondes.")
was_correct=$(gettext "Pour information, votre réponse \"%s\" était correcte. Soyez plus rapide la prochaine fois.")
was_incorrect=$(gettext "Pour information, votre réponse \"%s\" était incorrecte (attendu : \"%s\").")
regenerating=$(gettext "Génération d'un nouveau programme.")
seconds=$(gettext secondes)
recent_highscores=$(gettext "Meilleurs scores récents :")
enter_nickname=$(gettext "Entrez un pseudo ici qui apparaitra dans le highscore :")
try_again=$(gettext "Pour réessayer, cliquez ici :")
doc_ada=$(gettext '<a href="http://ensiwiki.ensimag.fr/index.php/Premiers_pas_avec_Emacs_et_Ada">Premiers pas avec Emacs et Ada</a>
sur EnsiWiki')
doc_python=$(gettext '<a href="http://ensiwiki.ensimag.fr/index.php/Premiers_pas_avec_Atom_et_Python">Premiers pas avec Atom et Python</a>
(ou <a href="http://ensiwiki.ensimag.fr/index.php/Premiers_pas_avec_Emacs_et_Python">Premiers pas avec Emacs et Python</a>)
sur EnsiWiki')
doc_c=$doc_ada

for v in title instructions the_answer_is invalid_answer \
         you_took correctly_compiled \
         next_step useless_comment enter_value_here click_here_to_reset \
	 remaining_text was_correct was_incorrect regenerating \
	 seconds recent_highscores enter_nickname try_again \
	 doc_ada doc_python doc_c
do
    value=$(eval "printf '%s\n\n' \"\$$v\"" | sed "s/'/\\\\'/g")
    printf "\$%s = '%s';\n" "$v" "$value" >> "$file"
done

shell_escape_string() {
    sed "s/'/\\\\'/g"
}

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
\$noise_python = array();
\$noise_python[] = '$(python_noise | shell_escape_string | tr '()' '[]')';
\$noise_python[] = '$(python_noise | shell_escape_string)';
\$noise_python[] = '$(python_noise | shell_escape_string)';
\$noise_python[] = '$(python_noise | shell_escape_string)';
\$noise_python[] = '$(python_noise | shell_escape_string)';
\$python_prog_header = 'from __future__ import print_function

$(python_header | shell_escape_string)';
?>
EOF

cat text-editor-template.php >>"$file"

chmod +x text-editor-$(gettext fr).php
