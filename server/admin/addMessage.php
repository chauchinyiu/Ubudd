<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 
session_start();
require '../Models/ConDB.php';

if (isset($_REQUEST['message_text'])) {
	$db = new ConDB();
	$stmt = $db->conn2->prepare("insert into broadcast (message) values (?)");
	$stmt->bind_param('s', $message);
	$message = $_REQUEST['message_text'];
	$stmt->execute();
	$stmt->close();
	$result = array('flag' => 0, 'message' => "Message added");	
	echo json_encode($result);
}
?>
