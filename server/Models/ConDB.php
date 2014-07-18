<?php

/**
 * Description of ConDB
 *
 * @author admin@3embed
 */
class ConDB {
    //put your code here
        
        private $serverName = ""; //serverName\instanceName
        private $userName = "root";//Database user name, ex: root
        private $pass = "Aea7QnibaB";//Database user password
        private $database = "sup";//Database name
        public $conn;
        public $flag_conn;
        public function __construct(){
                 $this->conn = mysql_connect($this->serverName, $this->userName,$this->pass);
                 if($this->conn) {
                     if(mysql_select_db($this->database,$this->conn)){
                               $this->flag_conn = 0;
                     }else{
                               $this->flag_conn = 1;
                               die( print_r( mysql_errors(), true));
                     }
                }else{
                     $this->flag_conn = 1;
                     die( print_r( mysql_error(), true));
                }
        }
}
?>
