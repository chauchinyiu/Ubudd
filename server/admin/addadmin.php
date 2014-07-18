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

if (is_array($dataRow)) {
    header('location: settings.php?error=1');
} else {
    $insertQry = "insert into admin(admin_username,admin_password) values('" . $_REQUEST['username'] . "','" . $_REQUEST['password'] . "')";
    mysql_query($insertQry, $db->conn);
}
header('location: settings.php?error=ok');
?>
