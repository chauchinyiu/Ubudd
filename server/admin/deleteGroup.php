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
	$stmt = $db->conn2->prepare("delete from chatGroup where id = ?");
	$stmt->bind_param('i', $id);
	$stmt2 = $db->conn2->prepare("delete from groupMember where groupID = ?");
	$stmt2->bind_param('i', $id);
	
	for ($i = 0; $i < $count; $i++) {
		$id = $list[$i];
		$stmt->execute();
		$stmt2->execute();
	}    
	$stmt->close();
	$stmt2->close();
	$result = array('flag' => 0, 'message' => "Chat group(s) deleted");	
	echo json_encode($result);
}
?>
