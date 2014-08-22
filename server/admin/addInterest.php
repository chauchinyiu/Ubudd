<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 
session_start();
require '../Models/ConDB.php';

if (isset($_REQUEST['interest_name'])) {
	$db = new ConDB();
	$stmt = $db->conn2->prepare("insert into interestBase (interestName) values (?)");
	$stmt->bind_param('s', $interestName);
	$interestName = $_REQUEST['interest_name'];
	$stmt->execute();
	$stmt->close();
	$result = array('flag' => 0, 'message' => "Interest added");	
	echo json_encode($result);
}
?>
