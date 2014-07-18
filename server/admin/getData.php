<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

session_start();
require '../Models/ConDB.php';
$db = new ConDB();

$getUsersQry = "select (select count(Entity_Id) from entity where DATE(Create_Dt) = CURDATE()) as today_users,(select count(e.Entity_Id) from entity e,entity_details ed where DATE(e.Create_Dt) = CURDATE() and e.Entity_Id = ed.Entity_Id and ed.Sex=1) as today_male_users,(select count(e.Entity_Id) from entity e,entity_details ed where DATE(e.Create_Dt) = CURDATE() and e.Entity_Id = ed.Entity_Id and ed.Sex = 2) as today_female_users from dual";
$getUsersRes = mysql_query($getUsersQry, $db->conn);

$todayData = mysql_fetch_assoc($getUsersRes);
//echo $getUsersQry;
echo json_encode($todayData);
?>
