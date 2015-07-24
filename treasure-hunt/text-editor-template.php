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
