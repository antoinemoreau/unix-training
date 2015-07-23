#!/bin/bash

. ./treasure-setup.sh
. ./spy-lib.sh
. ./i18n-lib.sh
. ./adalib.sh

file=text-editor-$(gettext fr).php

echo '<?php' >"$file"

instructions=$(gettext "Ci-dessous un programme Ada à compiler, avec plusieurs problèmes:
<ul>
<li>L'ensemble du programme est commenté, il faudra donc supprimer les <code>--</code> en début de ligne</li>
<li>L'auteur a utilisé des crochets [] au lieu des parenthèses ()</li>
<li>Il reste quelques erreurs de syntaxes</li>
</ul>
La mauvaise nouvelle, c'est que ce programme n'est valide que pendant %d secondes, il va donc falloir être rapide pour faire toutes ces corrections. Préparez-vous, et rechargez la page pour relancer le compte à rebours.
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

for v in instructions the_answer_is you_took correctly_compiled next_step useless_comment enter_value_here
do
    value=$(eval "printf '%s\n\n' \"\$$v\"" | sed "s/'/\\\\'/g")
    printf "\$%s = '%s';\n" "$v" "$value" >> "$file"
done

cat >>"$file" <<EOF
\$noise = array();
\$noise[] = '$(Noise | tr '()' '[]')';
\$noise[] = '$(Noise | tr '()' '[]')';
\$noise[] = '$(Noise | tr '()' '[]')';
\$noise[] = '$(Noise | tr '()' '[]')';
\$noise[] = '$(Noise | tr '()' '[]')';
?>
EOF

cat >>"$file" <<\EOF
<!DOCTYPE html>
<head>
<title>Text Editor</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>
<body>
<h1>Text editor</h1>
<?php
ini_set('display_errors', 'On');
error_reporting(E_ALL);

session_name('text_editor');
session_start();

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
$max_duration = 60.0;

if ($duration > $max_duration) {
	printf($you_took, $duration, $max_duration);
	echo '<br />';
	reset_session();
}

$id_expect = $_SESSION['id_expect'];

if ($id_expect == $id_actual) {
	printf($correctly_compiled, $duration);
	echo '<br />';
	echo preg_replace('/\n\n/', '<br /><br />', $next_step);
} else {
	$prog = '';
	$prog = '-- ' . $id_expect . "\n"; // Comment in real-life ;-)
	$i = 0;

	$prog .= sprintf('
	with Ada.Text_Io;
	use  Ada.Text_Io;

	procedure Text_Editor is
	begin
	put("%s ");
	', $the_answer_is);
	foreach (str_split($id_expect) as $char) {
		$i++;
		$prog .= $noise[($i + 2) % count($noise)];
		$prog .= "Put[\"\" & Character'Val(". (ord($char) - $i) ." + $i)];";
		if ($i % 2 == 0) {
			$prog .= "-- " . $useless_comment . "\n";
		}
		$prog .= $noise[$i % count($noise)];
		if ($i % 2 == 1) {
			$prog .= "-- " . $useless_comment . "\n";
		}
		if ($i == 1 || $i == 3 || $i == 7) {
			$prog .= "if 0 = 0 then Put(\"\"); end if\n";
		}

		if ($i == 6) {
			$prog .= "if 0 = 0 then Put(\"\"; end if;\n";
		}

		if ($i == 8) {
			$prog .= "if 0 == 0 then Put(\"\"); end if;\n";
		}
	}
	$prog .= '
	New_Line;
	end;
	';

	$prog = preg_replace('/^/m', '-- ', $prog);

	printf($instructions, $max_duration);
	echo '<br />';
	?>
	<textarea rows="10" cols="80">
	<?php echo $prog ?>
	</textarea>
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
