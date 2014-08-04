<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
 
session_start();
require '../Models/ConDB.php';
$db = new ConDB();

if (isset($_REQUEST['item_type'])) {

    if (!is_array($_REQUEST['item_list']))
        $list = explode(',', $_REQUEST['item_list']);
    else
        $list = $_REQUEST['item_list'];
    
	$count = count($list);
	$errorCnt = 0;
	$successCnt = 0;
	for ($i = 0; $i < $count; $i++) {
		$deleteUserQry = "delete from register where msisdn = '" . $list[$i] . "'";
		$deleteUserRes = mysql_query($deleteUserQry, $db->conn);

		$deleteUserQry = "delete from groupMember where memberID = '" . $list[$i] . "'";
		$deleteUserRes = mysql_query($deleteUserQry, $db->conn);
	}    
	$result = array('flag' => 0, 'message' => "User(s) deleted");	
	echo json_encode($result);
}
?>
