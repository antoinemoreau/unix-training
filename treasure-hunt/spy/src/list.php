<?php
define('_VALID_INCLUDE', TRUE);
include_once './inc/common.php';
include_once './inc/authentication.php';

exam_connect_maybe();
exam_header('Treasure Hunt monitoring');

echo '<script src="./sorttable.js"></script>';

echo '<p>Click on table headers to sort.</p>';

// http://www.php.net/manual/en/function.mysql-query.php#81348
// $format = tableau pour formatter l'affichage.
//    $format[$no_colonne] est une chaine de formattage :
//    - %s est remplacé par le contenu de la case.
//    - %b est remplacé par le contenu en remplacant les " " par &nbsp;
function echo_result($result, $format=null) {
	?><table class="sortable"><tr><?
	if(! $result) { ?><th>result not valid</th><? }
	else {
		$i = 0;
		while ($i < mysql_num_fields($result)) {
			$meta = mysql_fetch_field($result, $i);
			?><th style="white-space:nowrap"><?php echo($meta->name);?></th><?
			$i++;
		}
		?></tr><?
   
		if(mysql_num_rows($result) == 0) {
			?><tr><td colspan="<?php echo mysql_num_fields($result); ?>">
			<strong><center>no result</center></strong>
			</td></tr><?
		} else
			while($row=mysql_fetch_assoc($result)) {
				?><tr style="white-space:nowrap"><?
				foreach($row as $key=>$value) { 
					$value = htmlspecialchars($value);
					if ($format[$key]) {
						$snbsp = str_replace(" ", "&nbsp;", $value);
						$value = str_replace(array("%b", "%s"),
								     array($snbsp, $value),
								     $format[$key]);
					}
					echo '<td>'. $value .'</td>';
				}
				?></tr><?
			}
	}
	?></table><?
}

$query = 'SELECT DISTINCT hunt_access.step FROM hunt_access ORDER BY hunt_access.step;';
$result = exam_query($query);
$step_fields = '';
$step_join = '';
while($row=mysql_fetch_assoc($result)) {
	$step = $row['step'];
	if (preg_match('/^[a-zA-Z][a-zA-Z0-9]*$/', $step)) {
		// ignore potentially harmfull step names for security reason
		$step_fields .= ',
  MIN('. $step .'.date) as '. $step .'_date, COUNT(DISTINCT '. $step .'.date) as '. $step .'_nb';
		$step_join .= '
LEFT JOIN hunt_access as '. $step .'
  ON (reference.login = '. $step .'.login AND '. $step .".step = '". $step ."')";
	}
}

echo '<h2>Registered students accesses</h2>';

$query = 'SELECT reference.*'. $step_fields .'
FROM hunt_student AS reference'. $step_join .'
GROUP BY reference.login;';
// echo '<pre>'. $query .'</pre>';
$result = exam_query($query);
echo_result($result, array('login' => '<a href="http://intranet.ensimag.fr/ZENITH/affiche-etu.php?ETU=%s">%s</a>'));

echo '<h2>Unregistered students accesses</h2>';

$query = 'SELECT reference.login'. $step_fields .'
FROM (SELECT DISTINCT login
      FROM hunt_access
      WHERE login NOT IN (SELECT login FROM hunt_student)) AS reference'. $step_join .'
GROUP BY reference.login;';
// echo '<pre>'. $query .'</pre>';
$result = exam_query($query);
echo_result($result, array('login' => '<a href="http://intranet.ensimag.fr/ZENITH/affiche-etu.php?ETU=%s">%s</a>'));

exam_footer();
?>