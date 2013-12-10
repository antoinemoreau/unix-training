<?php
chdir('..');
define('_VALID_INCLUDE', TRUE);
include_once './inc/common.php';
include_once './inc/authentication.php';

if ($mode == 'demo')
	die("No answer available in demo mode");

if ($mode == "sql") {
	isset($subject) or die("FATAL ERROR: Subject not specified, please check config.php.");
	isset($session) or die("FATAL ERROR: Session not specified, please check config.php.");
}

$line = get_exam_info($subject);

exam_header(htmlspecialchars($line["desc"]), '..');

if (isset($_GET['machine_to_edit'])) {
	$machine_to_edit = $_GET['machine_to_edit'];
} else {
	$machine_to_edit = '';
}

if (isset($_GET['session_to_edit'])) {
	$session_to_edit = $_GET['session_to_edit'];
} else {
	$session_to_edit = '';
}

?>
<form action="change-machine.php" method="get">
	<fieldset class="invisiblefieldset">
	Machine : <input type="text" name="machine_to_edit" value="<?php echo htmlspecialchars($machine_to_edit) ?>" />
	Session : <input type="text" name="session_to_edit" value="<?php echo htmlspecialchars($session_to_edit) ?>" />
	<input type="submit" value="Get information" />
	</fieldset>
</form>
<?php

if ($machine_to_edit == "" || $session_to_edit == "") {
	exam_footer();
	exit;
}

$new_login = $_GET['new_login'];
$new_first_name = $_GET['new_first_name'];
$new_familly_name = $_GET['new_familly_name'];

if ($new_login != "" &&
    $new_first_name != "" &&
    $new_familly_name != "") {
	exam_query("UPDATE exam_unix_logins
                    SET login = '". exam_escape_string($new_login) ."',
                   first_name = '". exam_escape_string($new_first_name) ."',
                 familly_name = '". exam_escape_string($new_familly_name) ."'
                WHERE machine = '". exam_escape_string($machine_to_edit) ."'
                  AND session = '". exam_escape_string($session_to_edit) ."'
               AND id_subject = '". exam_escape_string($subject) ."'") or die ("Failed to change info for $login");
	echo "<p>Information updated for $machine_to_edit on session $session.</p>\n";
} else {
	echo "<p>Nothing to update.</p>\n";
}

$line = get_login($machine_to_edit, $session_to_edit, $subject);

$login = $line['login'];
$first_name = $line['first_name'];
$familly_name = $line['familly_name'];
$initial_login = $line['initial_login'];
$initial_first_name = $line['initial_first_name'];
$initial_familly_name = $line['initial_familly_name'];

if ($login == "")
	die("FATAL ERROR: Can not find login $login for subject $subject in database");
?>

<?php echo $welcome_msg ?>

<form action="change-machine.php" method="get">
	<fieldset class="invisiblefieldset">
	<input type="hidden" name="machine_to_edit" value="<?php echo htmlspecialchars($machine_to_edit) ?>" />
	<input type="hidden" name="session_to_edit" value="<?php echo htmlspecialchars($session_to_edit) ?>" />
	<div class="info"><ul>
	<li><strong>Machine: <?php echo $machine_to_edit ?></strong></li>
	<li><strong>Session: <?php echo $session_to_edit ?></strong></li>
	<li><strong>Login:
	    <input type="text" name="new_login" value="<?php echo htmlspecialchars($login) ?>" />
	    (was <?php echo $initial_login ?>)</strong></li>
	<li><strong>First Name:
	    <input type="text" name="new_first_name" value="<?php echo htmlspecialchars($first_name) ?>" />
	    (was <?php echo $initial_first_name ?>)</strong></li>
	<li><strong>Familly Name:
	    <input type="text" name="new_familly_name" value="<?php echo htmlspecialchars($familly_name) ?>" />
	    (was <?php echo $initial_familly_name ?>)</strong></li>
	</ul></div>
	<input type="submit" value="Change information" />
	</fieldset>
</form>

<p><a href="stats.php">See stats</a></p>
<?php
exam_footer();
?>