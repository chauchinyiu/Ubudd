<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 
session_start();
require '../Models/ConDB.php';
require '../Models/APNS.php';

if (isset($_REQUEST['item_type'])) {
	
	$ap = new Apsn();

    if (!is_array($_REQUEST['item_list']))
        $list = explode(',', $_REQUEST['item_list']);
    else
        $list = $_REQUEST['item_list'];
    
	$count = count($list);
	
	for ($i = 0; $i < $count; $i++) {
		$userId = $list[$i];
		$err = $ap->sendNotification($userId, "Testing APNS", array('type' => 'ubudd admin'));
	} 
	 
	$result = array('flag' => 0, 'message' => $err);	
	echo json_encode($result);
}
?>
