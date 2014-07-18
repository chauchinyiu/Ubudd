<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

if (isset($_REQUEST['item_type'])) {

    if (!is_array($_REQUEST['item_list']))
        $list = explode(',', $_REQUEST['item_list']);
    else
        $list = $_REQUEST['item_list'];
    
    
}
?>
