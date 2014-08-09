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
	
	$stmt = $db->conn2->prepare("update chatGroup set Disabled = ? where id = ?");
	
	$stmt->bind_param('ii', $trueVal, $id);
	
	for ($i = 0; $i < $count; $i++) {	
		$trueVal = 1;
		$id = $list[$i];
		$stmt->execute();
	}    
	$stmt->close();
	
	$result = array('flag' => 0, 'message' => "Chat group(s) disabled");	
	echo json_encode($result);
}
?>
