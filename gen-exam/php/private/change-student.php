<?php
define('_VALID_INCLUDE', TRUE);
chdir('..');
include_once './inc/common.php';
include_once './inc/authentication.php';

$cango = True;

if ($mode == 'demo')
	die("Changing machine not available in demo mode");

if ($mode == "sql") {
	isset($subject) or die("FATAL ERROR: Subject not specified, please check config.php.");
	isset($session) or die("FATAL ERROR: Session not specified, please check config.php.");
}

$line = get_exam_info($subject);

exam_header(htmlspecialchars($line["desc"]), '..');

if (isset($_GET['confirm']) && $_GET['confirm'] == "true") {
	$confirm = True;
} else {
	$confirm = False;
}

if (isset($_GET['login_to_edit'])) {
	$login_to_edit = $_GET['login_to_edit'];
} else {
	$login_to_edit = '';
	$confirm = False;
}

if (isset($_GET['old_machine'])) {
	$old_machine = $_GET['old_machine'];
} else {
	$old_machine = '';
	$confirm = False;
}

if (isset($_GET['family_name'])) {
	$family_name = $_GET['family_name'];
} else {
	$family_name = '';
	$confirm = False;
}

if (isset($_GET['first_name'])) {
	$first_name = $_GET['first_name'];
} else {
	$first_name = '';
	$confirm = False;
}

if (isset($_GET['student_id'])) {
	$student_id = $_GET['student_id'];
} else {
	$student_id = '';
	$confirm = False;
}

if (isset($_GET['new_machine'])) {
	$new_machine = $_GET['new_machine'];
} else {
	$new_machine = '';
	$confirm = False;
}

if (isset($_GET['session_to_edit'])) {
	$session_to_edit = $_GET['session_to_edit'];
} else {
	$session_to_edit = $session;
	$confirm = False;
}

if (isset($_GET['hidden_login_to_edit']) &&
    $_GET['hidden_login_to_edit'] != $login_to_edit) {
	$family_name = "";
	$first_name = "";
	$student_id = "";
	$old_machine = "";
}

if ($confirm) {
	$query_new = "UPDATE exam_unix_logins
                    SET login = '". exam_escape_string($login_to_edit) ."',
                   first_name = '". exam_escape_string($first_name) ."',
                 familly_name = '". exam_escape_string($family_name) ."',
                   student_id = '". exam_escape_string($student_id) ."'
                WHERE machine = '". exam_escape_string($new_machine) ."'
                  AND session = '". exam_escape_string($session_to_edit) ."'
               AND id_subject = '". exam_escape_string($subject) ."'";

	$query_old = "UPDATE exam_unix_logins
                    SET login = 'disabled',
                   first_name = 'disabled',
                 familly_name = 'disabled',
                   student_id = 'disabled'
                WHERE machine = '". exam_escape_string($old_machine) ."'
                  AND session = '". exam_escape_string($session_to_edit) ."'
               AND id_subject = '". exam_escape_string($subject) ."'";

	echo $query_new;
	echo '<br />';
	echo $query_old;
	echo '<br />';
	exam_query($query_new) or die ("Failed to change info for $login");

	exam_query($query_old) or die ("Failed to change info for $login");
}


if ($login_to_edit != "") {
	$query = "SELECT *
FROM exam_unix_logins
WHERE login ='" . exam_escape_string($login_to_edit) . "';";
	$result_login = exam_query($query);

	$num_rows = exam_num_rows($result_login);

	echo "<h2>Student to move</h2>";

	exam_display_result($result_login);

	$result_login = exam_query($query); // Brute force, redo the
					    // query since
					    // exam_display_result()
					    // consumed it.
	$result_login = exam_fetch_array($result_login);
	if ($old_machine == "") {
		$old_machine = $result_login['machine'];
	}
	if ($first_name == "") {
		$first_name = $result_login['first_name'];
	}
	if ($family_name == "") {
		$family_name = $result_login['familly_name'];
	}
	if ($student_id == "") {
		$student_id = $result_login['student_id'];
	}
	

	if ($num_rows != 1) {
		echo("There should be exactly one login entry");
		$cango = False;
	}
} else {
	$cango = False;
}

if ($new_machine != "") {
	$result_machine = exam_query("SELECT *
FROM exam_unix_logins
WHERE machine ='" . exam_escape_string($new_machine) . "'
  AND session ='" . exam_escape_string($session_to_edit) . "';");

	$num_rows = exam_num_rows($result_machine);

	echo "<h2>Spare machine to use</h2>";
	
	exam_display_result($result_machine);

	if ($num_rows != 1) {
		echo("There should be exactly one machine entry, not " . $num_rows . ".");
		$cango = False;
	}
} else {
	$cango = False;
}
?>
<form action="change-student.php" method="get">
	<fieldset class="invisiblefieldset">
	Login : <input type="hidden" name="hidden_login_to_edit" value="<?php echo htmlspecialchars($login_to_edit) ?>" />
	Login : <input type="text" name="login_to_edit" value="<?php echo htmlspecialchars($login_to_edit) ?>" />
	Session : <input type="text" name="session_to_edit" value="<?php echo htmlspecialchars($session_to_edit) ?>" />
	<br />
	Old machine : <input type="text" name="old_machine" value="<?php echo htmlspecialchars($old_machine) ?>" />
	First name : <input type="text" name="first_name" value="<?php echo htmlspecialchars($first_name) ?>" />
	Family name : <input type="text" name="family_name" value="<?php echo htmlspecialchars($family_name) ?>" />
	Student id : <input type="text" name="student_id" value="<?php echo htmlspecialchars($student_id) ?>" />
	<br />
	New machine : <input type="text" name="new_machine" value="<?php echo htmlspecialchars($new_machine) ?>" />
	<br />
	<?php if ($cango) { ?>
        Confirm: <input type="checkbox" name="confirm" value="true">
	<br />
        <?php } ?>
	<input type="submit" value="<?php if ($cango) { echo "GO"; } else { echo "Get information"; }; ?>" />
	</fieldset>
</form>
<p><a href="stats.php">See stats</a></p>

<?php

exam_footer();