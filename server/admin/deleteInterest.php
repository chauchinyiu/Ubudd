<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 
session_start();
require '../Models/ConDB.php';

if (isset($_REQUEST['item_type'])) {
	$db = new ConDB();

    if (!is_array($_REQUEST['item_list']))
        $list = explode(',', $_REQUEST['item_list']);
    else
        $list = $_REQUEST['item_list'];
    
	$count = count($list);
	$errorCnt = 0;
	$successCnt = 0;
	$stmt = $db->conn2->prepare("delete from interestBase where interestID = ?");
	$stmt->bind_param('s', $interestId);
	
	for ($i = 0; $i < $count; $i++) {
		$interestId = $list[$i];
		$stmt->execute();
	}    
	$stmt->close();
	$result = array('flag' => 0, 'message' => "Interest(s) deleted");	
	echo json_encode($result);
}
?>
