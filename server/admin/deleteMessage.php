<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 
session_start();
require '../Models/ConDB.php';

$target_dir = "/var/www/html/uploads/";

if (isset($_REQUEST['item_type'])) {
	$db = new ConDB();

    if (!is_array($_REQUEST['item_list']))
        $list = explode(',', $_REQUEST['item_list']);
    else
        $list = $_REQUEST['item_list'];
    
    
	$count = count($list);
	$errorCnt = 0;
	$successCnt = 0;
	
	
	$getQry = $db->conn2->prepare("select message from broadcast where isImage = 1 AND id = ?");	
	$getQry->bind_param('s', $messageID);
	
	for ($i = 0; $i < $count; $i++) {
		$messageID = $list[$i];
		
    	$getQry->execute();
	    $result = $getQry->get_result();
    	while ($row = $result->fetch_assoc()){
        	$target_file = $target_dir.$row['message'];
        	unlink($target_file);				    	
    	}

	}  
	  
	$getQry->close();
	
	$stmt = $db->conn2->prepare("delete from broadcast where id = ?");
	$stmt->bind_param('s', $messageID);
	
	for ($i = 0; $i < $count; $i++) {
		$messageID = $list[$i];
		$stmt->execute();
	}    
	$stmt->close();
	$result = array('flag' => 0, 'message' => "Message(s) deleted");	
	echo json_encode($result);
}
?>
