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

for v in title instructions the_answer_is you_took correctly_compiled \
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

cat >>"$file" <<\EOF
<?php
ini_set('display_errors', 'On');
error_reporting(E_ALL);

session_name('text_editor');
session_start();

$language = 'ada';
if (isset($_GET['language']) && $_GET['language'] == 'c') {
	$language = 'c';
}

if ($language == 'c') {
	$prog_header = '#include <stdio.h>

int main(void) {';
	$prog_footer = '}';
	$language_name = 'C';
	$comment_prefix = '//';
	$new_line = 'printf("\n");';
	$the_answer_is_prog = sprintf('printf("%%s ", "%s");', $the_answer_is);
	$noise = $noise_c;
	$error1 = "if (0 == 0) printf(\"\")\n";
	$error2 = "if (0 == 0) printf(\"\";\n";
	$error3 = "if (0 = 0)  printf(\"\");\n";
	function display_value($i, $char) {
		return 'printf("%c", ' . (ord($char) - $i) ." + $i);";
	}
	$otherlanguage = 'ada';
	$otherlanguage_name = 'Ada';
} else {
	$prog_header = 'with Ada.Text_Io;
	use  Ada.Text_Io;

	procedure Text_Editor is
	begin';
	$prog_footer = 'end;';
	$language_name = 'Ada';
	$comment_prefix = '--';
	$new_line = 'New_Line;';
	$the_answer_is_prog = sprintf('put("%s ");', $the_answer_is);
	$noise = $noise_ada;
	$error1 = "if 0 = 0 then Put(\"\"); end if\n";
	$error2 = "if 0 = 0 then Put(\"\"; end if;\n";
	$error3 = "if 0 == 0 then Put(\"\"); end if;\n";
	function display_value($i, $char) {
		return "Put(\"\" & Character'Val(". (ord($char) - $i) ." + $i));";
	}
	$otherlanguage = 'c';
	$otherlanguage_name = 'C';
}

function reset_session() {
	global $id_actual;
	$_SESSION['id_expect'] = uniqid('', true);
	$_SESSION['timestamp'] = gettimeofday(true);
	$id_actual = "";
}

if (!isset($_SESSION['id_expect']) || !isset($_SESSION['timestamp'])) {
	reset_session();
}

if (isset($_POST['id_actual']) && $_POST['id_actual'] != '') {
	$id_actual = $_POST['id_actual'];
} else {
	$id_actual = "";
	reset_session();
};

$duration = gettimeofday(true) - $_SESSION['timestamp'];
$max_duration = 90.0;

if ($duration > $max_duration) {
	printf($you_took, $duration, $max_duration);
	echo '<br />';
	reset_session();
}

$id_expect = $_SESSION['id_expect'];

function useless_comment_maybe($cond) {
	global $prog, $comment_prefix, $useless_comment;
	if ($cond) {
		$prog .= $comment_prefix . $useless_comment . "\n";
	}
}
?>

<!DOCTYPE html>
<head>
<title><?php echo $title ?></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h1><?php echo $title ?></h1>
<?php
if ($id_expect == $id_actual) {
	printf($correctly_compiled, $duration);
	echo '<br />';
	echo preg_replace('/\n\n/', '<br /><br />', $next_step);
} else {
	$prog = '';
	// $prog = $comment_prefix . $id_expect . "\n"; // Comment out in real-life ;-)
	$i = 0;

	$prog .= $prog_header . "\n";
	$prog .= $the_answer_is_prog;
	foreach (str_split($id_expect) as $char) {
		$i++;
		$prog .= $noise[($i + 2) % count($noise)];
		$prog .= strtr(display_value($i, $char), '()', '[]');;
		useless_comment_maybe($i % 2 == 0);
		if ($i % 3 == 0) {
			$prog .= $noise[$i % count($noise)];
		}
		useless_comment_maybe($i % 2 == 1);
		if ($i == 1 || $i == 3 || $i == 7) {
			$prog .= "\n" . $error1 . "\n";
		}

		if ($i == 6) {
			$prog .= "\n" . $error2 . "\n";
		}

		if ($i == 8) {
			$prog .= "\n" . $error3 . "\n";
		}
	}
	$prog .= $new_line . "\n";
	$prog .= $prog_footer;

	$prog = preg_replace('/^/m', $comment_prefix . ' ', $prog);

	printf($instructions, $language_name, $otherlanguage, $otherlanguage_name, $comment_prefix, $max_duration);
	echo '<br />';
	?>
	<textarea rows="10" cols="80"><?php echo $prog ?></textarea>
	<form method="POST">
		<?php echo $enter_value_here ?> <input name="id_actual" type="text"   value="" />
		<input type="submit" />
	</form>
	<?php
}
?>
</body>
EOF

chmod +x text-editor-$(gettext fr).php
