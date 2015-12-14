<?php
		
// global to hold filename constructed from ISBN
$localFile = '';

$isbn = '9814287229';
$localFile = glob('images/covers/large/' . $isbn . '_*.jpg')[0];
var_dump($localFile);



?>
