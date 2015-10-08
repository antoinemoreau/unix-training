<?php
ini_set('display_errors', 'On');
error_reporting(E_ALL);

session_name('hunt_text_editor');
session_start();

$max_duration_base = 120.0;
$extra_time1 = 100.0;

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

$session_restored = False;

function reset_session() {
	global $id_actual, $session_restored, $id_expect;
	$_SESSION['id_expect'] = uniqid('', true);
	$_SESSION['timestamp'] = gettimeofday(true);
	$_SESSION['moretime'] = False;
	$id_actual = "";
	$id_expect = $_SESSION['id_expect'];
	$session_restored = True;
}

if (!isset($_SESSION['id_expect']) || !isset($_SESSION['timestamp'])) {
	// First visit?
	reset_session();
}

if (isset($_POST['reset_session'])) {
	// Explicit reset. Redirect to the same page without POST
	// arguments to avoid weird behavior on reload.
	reset_session();
	$_SESSION['message'] = $regenerating;
	header('Location: ' . $_SERVER['REQUEST_URI']);
	exit;
}

if (isset($_POST['id_actual']) && $_POST['id_actual'] != '') {
	$id_actual = trim($_POST['id_actual']);
} else {
	$id_actual = "";
}

if (isset($_POST['nickname'])) {
	$_SESSION['nickname'] = $_POST['nickname'];
}

$max_duration = $max_duration_base;
$duration = gettimeofday(true) - $_SESSION['timestamp'];
$id_expect = trim($_SESSION['id_expect']);
$message = null;

if (isset($_SESSION['message'])) {
	$message = $_SESSION['message'];
	unset($_SESSION['message']);
}

if ($id_actual == "moretime") {
	$_SESSION['moretime'] = True;
	$message = 'Extra time!';
	$id_actual = '';
} else if ($id_actual == "lesstime") {
	$_SESSION['moretime'] = False;
	$message = 'Extra time canceled!';
	$id_actual = '';
}


if ($_SESSION['moretime']) {
	$max_duration += $extra_time1;
}

function useless_comment_maybe($cond) {
	global $prog, $comment_prefix, $useless_comment;
	if ($cond) {
		$prog .= $comment_prefix . $useless_comment . "\n";
	}
}

function generate_obfuscated_prog($id_actual) {
	global $prog_header, $the_answer_is_prog, $id_expect, $noise, $noise,
		$error1, $error2, $error3,
		$new_line, $prog_footer, $comment_prefix;
	$prog = '';
	$prog .= $comment_prefix . ' ' . date("Y-m-d H:i:s", $_SESSION['timestamp']) . "\n";
	// $prog .= $comment_prefix . $id_expect . "\n"; // Comment out in real-life ;-)
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
	return $prog;
}

function sort_score($a, $b) {
	if($a['duration'] == $b['duration']) {
		return 0;
	}
	return ($a['duration'] > $b['duration']) ? 1 : -1;
}

function high_scores($duration) {
	global $id_actual;
	global $seconds, $recent_highscores, $enter_nickname, $try_again;
	$lockname = "/tmp/unix-hunt-highscores.lock";
	$dataname = "/tmp/unix-hunt-highscores.json";
	$fp = fopen($lockname, "w+");

	if ((!isset($_SESSION['highscore'])) ||
	    $duration < $_SESSION['highscore']) {
		$_SESSION['highscore'] = $duration;
	}

	if (!isset($_SESSION['nickname'])) {
		if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
			$_SESSION['nickname'] = $_SERVER['HTTP_X_FORWARDED_FOR'];
		} else {
			$_SESSION['nickname'] = $_SERVER['REMOTE_ADDR'];
		}
	}

	if (flock($fp, LOCK_EX)) {
		if (file_exists($dataname)) {
			$high = json_decode(file_get_contents($dataname),
					    True);
		} else {
			$high = array();
		}
		$high[session_id()] = array('duration' => $_SESSION['highscore'],
					    'name' => $_SESSION['nickname']);
		uasort($high, 'sort_score');
		array_splice($high, 20);
		file_put_contents($dataname, json_encode($high));
		flock($fp, LOCK_UN);
		echo $recent_highscores . "<ol>";
		$current_has_highscore = False;
		foreach ($high as $id => $player) {
			if ($id == session_id()) {
				$fmt1 = '<strong>';
				$fmt2 = '</strong>';
				$current_has_highscore = True;
			} else {
				$fmt1 = '';
				$fmt2 = '';
			}
			printf("<li>%s%01.1f %s : %s%s</li>", $fmt1, $player['duration'], $seconds, htmlspecialchars($player['name']), $fmt2);
		}
		echo "</ol>";
		if ($current_has_highscore) { ?>
		<form method="POST">
			<?php echo $enter_nickname; ?> <input name="nickname" type="text"   value="" />
			<input name="id_actual" type="hidden"   value="<?php echo htmlspecialchars($id_actual); ?>" />
			<input type="submit" />
		</form> <?php
		}
		?>
		<form method="POST">
			<?php echo $try_again; ?>
			<input name="reset_session" type="hidden" value="yesPlease" />
			<input type="submit" value="Génération" />
		</form>
		 <?php
	} else {
		echo "Could not lock highscore file, sorry.";
	}

	fclose($fp);
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

if ($message != null) {
	echo $message;
	echo '<br />';
}

if ($duration > $max_duration) {
	printf($you_took, $duration, $max_duration);
	echo '<br />';
	if ($id_actual != "") {
		if ($id_expect == $id_actual) {
			printf($was_correct, htmlspecialchars($id_actual));
		} else {
			printf($was_incorrect, htmlspecialchars($id_actual), htmlspecialchars($id_expect));
		}
		echo '<br />';
	}
	reset_session();
}

if ($id_expect == $id_actual) {
	printf($correctly_compiled, $duration);
	echo '<br />';
	high_scores($duration);
	echo '<br />';
	echo preg_replace('/\n\n/', '<br /><br />', $next_step);
} else {
	if ($id_actual != "") {
		printf($invalid_answer . '<br />', $id_actual, $duration);
	}
	$prog = generate_obfuscated_prog($id_expect);

	printf($instructions, $language_name, $otherlanguage, $otherlanguage_name, $comment_prefix, $max_duration);
	echo '<br />';
	if (!$session_restored) {
		printf($remaining_text, $max_duration - $duration);
		echo '<br />';
	}
	?>
	<textarea rows="10" cols="80"><?php echo $prog ?></textarea>
	<form method="POST">
		<?php echo $enter_value_here ?> <input name="id_actual" type="text"   value="" />
		<input type="submit" />
	</form>
	<form method="POST">
		<?php echo $click_here_to_reset ?>
		<input name="reset_session" type="hidden" value="yesPlease" />
		<input type="submit" value="Génération" />
	</form>
	<?php
}
?>
</body>
