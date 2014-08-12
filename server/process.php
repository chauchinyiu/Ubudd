<?php

require_once 'Models/API.php';
require_once 'Models/ConDB.php';
require_once "twilio-php/Services/Twilio.php";

class MyAPI extends API {

    protected $User;
    private $db;

    public function __construct($request_uri, $postData, $origin) {

        parent::__construct($request_uri, $postData);

        $this->db = new ConDB();
    }

    /*              ----------------                SERVICE METHODS             ---------------------               */
    /*
     * Method name: register
     * Desc: Sign up for the app
     * Input: Request data
     * Output:  Success flag with data array if completed successfully, else data array with error flag
     */

    protected function register($args) {
//echo 2;
        if ($args['msisdn'] == '' || $args['brand'] == '' || $args['model'] == '' || $args['os'] == '' || $args['uid'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');


		$stmt = $this->db->conn2->prepare("select email from register where email = ?");
		$stmt->bind_param('s', $userId);
		$userId = $args['msisdn'] . "@mobifyi.com";
		$stmt->execute();
		$stmt->bind_result($verifyEmailRes);

        $account_sid = 'AC5cf3e259d9f0842517d370885e914aff';
        $auth_token = '6573f29127cac058d60422c565e5d32e';
        $client = new Services_Twilio($account_sid, $auth_token);
        $rand = rand(100000, 999999);

        $message = $client->account->messages->create(array(
            'To' => $args['msisdn'],
            'From' => "+19063563715",
            'Body' => "Your verification code for login into Ubudd: " . $rand,
        ));
        

        if ($stmt->fetch()) {
	        $stmt->close();
			$stmt = $this->db->conn2->prepare("update register set ver_number = ? where msisdn = ?");
			$stmt->bind_param('ss', $rand, $userId);
			$userId = $args['msisdn'];
			$stmt->execute();
			$stmt->close();
            //$updateVerificationNumberQry = "update register set ver_number = '" . $rand . "' where msisdn = '" . $args['msisdn'] . "'";
            //mysql_query($updateVerificationNumberQry, $this->db->conn);
            return array('error' => 0, 'message' => 'Login successful', 'data' => array('email' => $args['msisdn'] . "@mobifyi.com", 'password' => $args['msisdn']));
        } else {
	        $stmt->close();
			$stmt = $this->db->conn2->prepare("insert into register values(?, ?, ?, ?, ?, ?, ?, ?, '-1', '', '999', '999', '', '0', NULL)");
			$stmt->bind_param('ssssssss', $userId, $brand, $model, $os, $uid, $email, $pwd, $rand);
			$userId = $args['msisdn'];
			$brand = $args['brand'];
			$model = $args['model'];
			$os = $args['os'];
			$uid = $args['uid'];
			$email = $args['msisdn'] . "@mobifyi.com";
			$pwd = $args['msisdn'];
			$stmt->execute();
			$stmt->close();

            //$insertQry = "insert into register values('" . $args['msisdn'] . "','" . $args['brand'] . "','" . $args['model'] . "','" . $args['os'] . "','" . $args['uid'] . "','" . $args['msisdn'] . "@mobifyi.com" . "','" . $args['msisdn'] . "','" . $rand . "', '-1', '', '999', '999', '', '0')";
            //mysql_query($insertQry, $this->db->conn);
            return array('error' => 0, 'message' => 'Signup successful', 'data' => array('email' => $args['msisdn'] . "@mobifyi.com", 'password' => $args['msisdn']));
        }
    }

    protected function verifyUser($args) {

        if ($args['msisdn'] == '' || $args['number'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("select ver_number from register where email = ?");
		$stmt->bind_param('s', $userId);
		$userId = $args['msisdn'] . "@mobifyi.com";
		$stmt->execute();
		$verifyEmailRes = $stmt->get_result();


        //$verifyEmailQry = "select ver_number from register where email = '" . $args['msisdn'] . "@mobifyi.com'";
        //$verifyEmailRes = mysql_query($verifyEmailQry, $this->db->conn);
        $verifyRow = mysqli_fetch_assoc($verifyEmailRes);

        if ($verifyRow['ver_number'] == $args['number']) {
			$stmt = $this->db->conn2->prepare("update register set ver_number = '' where msisdn = ?");
			$stmt->bind_param('s', $userId);
			$userId = $args['msisdn'];
			$stmt->execute();
        	$stmt->close();
            //$updateVerificationNumberQry = "update register set ver_number = '' where msisdn = '" . $args['msisdn'] . "'";
            //mysql_update($updateVerificationNumberQry, $this->db->conn);
            return array('error' => 0, 'message' => 'Verified Successfully');
        } else {
            return array('error' => 1, 'message' => 'Verification failed');
        }
    }


    protected function updateAPNSToken($args) {

        if ($args['msisdn'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("update register set apnsToken = ? where email = ?");
		$stmt->bind_param('ss', $token, $userId);
		$token = $args['token'];
		$userId = $args['msisdn'] . "@mobifyi.com";
		$stmt->execute();
		$stmt->close();
		return array('error' => 0, 'message' => 'Token updated');
    }

}

if (!array_key_exists('HTTP_ORIGIN', $_SERVER)) {

    $_SERVER['HTTP_ORIGIN'] = $_SERVER['SERVER_NAME'];
}

try {

    $API = new MyAPI($_SERVER['REQUEST_URI'], $_REQUEST, $_SERVER['HTTP_ORIGIN']);

    echo $API->processAPI();
} catch (Exception $e) {

    echo json_encode(Array('error' => $e->getMessage()));
}
?>