<?php


class Apsn {
    //put your code here
        private $passphrase = 'Ubudd';

        public function __construct(){

        }

        public function sendNotification($userID, $message, $customVals){
        	$ctx = stream_context_create();
			stream_context_set_option($ctx, 'ssl', 'passphrase', 'Ubudd');
			stream_context_set_option($ctx, 'ssl', 'cafile', '/var/www/html/Models/centrust_2048_ca.cer');
			stream_context_set_option($ctx, 'ssl', 'local_cert', '/var/www/html/Models/ck.pem');
			$fp = stream_socket_client("ssl://gateway.sandbox.push.apple.com:2195", $errno, $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
			if (!$fp) {
				return "ERROR:" . $errstr;
			} 
			
			// Create the payload body
			$body['aps'] = array(
				'alert' => $message,
				'sound' => 'default'
				);
			$body['ubuddcustom'] = $customVals;

			// Encode the payload as JSON
			$payload = json_encode($body);


			//read device token
			$db = new ConDB();
			
            $getUsersQry = "select apnsToken from register where msisdn like '%" . $userID. "%' ";                            
            $getUsersRes = $db->conn2->query($getUsersQry);
                                        
            if ($user = $getUsersRes->fetch_assoc()) {
				// Build the binary notification
				$msg = chr(0) . pack('n', 32) . pack('H*', $user['apnsToken']) . pack('n', strlen($payload)) . $payload;
            }
			// Send it to the server
			$result = fwrite($fp, $msg, strlen($msg));
			// Close the connection to the server
			fclose($fp);
        }
        
        public function sendNotificationToAll($message, $customVals){
        	$ctx = stream_context_create();
			stream_context_set_option($ctx, 'ssl', 'passphrase', 'Ubudd');
			stream_context_set_option($ctx, 'ssl', 'cafile', '/var/www/html/Models/centrust_2048_ca.cer');
			stream_context_set_option($ctx, 'ssl', 'local_cert', '/var/www/html/Models/ck.pem');
			$fp = stream_socket_client("ssl://gateway.sandbox.push.apple.com:2195", $errno, $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);
			if (!$fp) {
				return "ERROR:" . $errstr;
			} 
			
			// Create the payload body
			$body['aps'] = array(
				'alert' => $message,
				'sound' => 'default'
				);
			$body['ubuddcustom'] = $customVals;

			// Encode the payload as JSON
			$payload = json_encode($body);


			//read device token
			$db = new ConDB();
			
            $getUsersQry = "select apnsToken from register where not apnsToken is null ";                            
            $getUsersRes = $db->conn2->query($getUsersQry);
                       
            $res = $db->conn2->query($getUsersQry);
            while ($user = $res->fetch_assoc()) {
				$msg = chr(0) . pack('n', 32) . pack('H*', $user['apnsToken']) . pack('n', strlen($payload)) . $payload;
				// Send it to the server
				$result += fwrite($fp, $msg, strlen($msg));
            }           
                                        
			// Close the connection to the server
			fclose($fp);
			return $result;
        }
        
}
?>
