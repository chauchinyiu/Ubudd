<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
session_start();
require '../Models/ConDB.php';
$db = new ConDB();

$selectUserQry = "select * from admin where admin_username = '" . $_REQUEST['username'] . "' and admin_password='" . $_REQUEST['password'] . "'";
$selectUserRes = mysql_query($selectUserQry, $db->conn);

$dataRow = mysql_fetch_assoc($selectUserRes);

if (is_array($dataRow) && $dataRow['admin_password'] == $_REQUEST['password']) {

    $_SESSION['admin_id'] = $dataRow['aid'];
    $_SESSION['session'] = time() + 60 * 60;
    header('location: users.php');
} else {
    header('location: index.php?error=1');
//    echo $selectUserQry;
}
?>
