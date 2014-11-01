<?php

require_once 'Models/API.php';
require_once 'Models/ConDB.php';
require_once 'Models/APNS.php';

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
        if ($args['msisdn'] == '' || $args['brand'] == '' || $args['model'] == '' || $args['os'] == '' || $args['uid'] == '' || $args['countryCode'] == '' || $args['phoneNo'] == '')
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

            return array('error' => 0, 'message' => 'Login successful', 'data' => array('email' => $args['msisdn'] . "@mobifyi.com", 'password' => $args['msisdn']));
        } else {
	        $stmt->close();
			$stmt = $this->db->conn2->prepare("insert into register values(?, ?, ?, ?, ?, ?, ?, ?, '-1', '', '999', '999', '', '0', NULL, ?, ?, '', NULL, NULL, NULL)");
			$stmt->bind_param('ssssssssss', $userId, $brand, $model, $os, $uid, $email, $pwd, $rand, $countryCode, $phoneNo);
			$userId = $args['msisdn'];
			$brand = $args['brand'];
			$model = $args['model'];
			$os = $args['os'];
			$uid = $args['uid'];
			$email = $args['msisdn'] . "@mobifyi.com";
			$pwd = $args['msisdn'];
			$countryCode = $args['countryCode'];
			$phoneNo = $args['phoneNo'];
			$stmt->execute();
			$stmt->close();

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

    protected function updateUserField($args) {

        if ($args['msisdn'] == '' || $args['field'] == '' || $args['value'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("update register set " . $args['field'] . " = ? where email = ?");
		$stmt->bind_param('ss', $value, $userId);
		$value = $args['value'];
		$userId = $args['msisdn'] . "@mobifyi.com";
		$stmt->execute();
		$stmt->close();
		return array('error' => 0, 'message' => $args['field'] . ' updated');
    }

    protected function verifyC2CallID($args) {

        if ($args['c2CallID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("select c2CallID from register where c2CallID = ?");
		$stmt->bind_param('s', $c2CallID);
		$c2CallID = $args['c2CallID'];
		$stmt->execute();
		$verifyRes = $stmt->get_result();

        $verifyRow = mysqli_fetch_assoc($verifyRes);

        if ($verifyRow['c2CallID'] == $args['c2CallID']) {
            return array('error' => 0, 'message' => 'Verified Successfully', 'c2CallID' => $args['c2CallID'], 'resultCode' => 1);
        } else {
            return array('error' => 1, 'message' => 'Verification failed', 'c2CallID' => $args['c2CallID'], 'resultCode' => 0);
        }
    }

    protected function readUserInfo($args) {

        if ($args['c2CallID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("select c2CallID, interestID, interestDescription, dob, gender, userName, countryCode, phoneNo from register where c2CallID = ?");
		$stmt->bind_param('s', $c2CallID);
		$c2CallID = $args['c2CallID'];
		$stmt->execute();
		$verifyRes = $stmt->get_result();

        $verifyRow = mysqli_fetch_assoc($verifyRes);

        if ($verifyRow['c2CallID'] == $args['c2CallID']) {
            return array('error' => 0, 'message' => 'Read Successfully', 
            'interestID' => $verifyRow['interestID'], 
            'interestDescription' => $verifyRow['interestDescription'], 
            'dob' => $verifyRow['dob'],
            'gender' => $verifyRow['gender'],
            'userName' => $verifyRow['userName'],
            'countryCode' => $verifyRow['countryCode'],
            'phoneNo' => $verifyRow['phoneNo'],
            'resultCode' => 1);
        } else {
            return array('error' => 1, 'message' => 'Read failed', 'resultCode' => 0);
        }
    }


    protected function addChatGroup($args) {
        if ($args['groupAdmin'] == '' || $args['c2CallID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');


		$stmt = $this->db->conn2->prepare("insert into chatGroup " 
		. "(topicDescription, groupAdmin, interestID, interestDescription, locationLag, locationLong, locationName, Disabled, c2CallID, isPublic, topic) "
		. "values(?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?)");
		$stmt->bind_param('ssssssssss', $topicDescription, $groupAdmin, $interestID, $interestDescription, $latCoord, $longCoord, $location, $c2CallID, $isPublic, $topic);
		$topicDescription = $args['topicDescription'];
		$groupAdmin = $args['groupAdmin'];
		$interestID = $args['interestID'];
		$interestDescription = $args['interestDescription'];
		$latCoord = $args['latCoord'];
		$longCoord = $args['longCoord'];
		$location = $args['location'];
		$c2CallID = $args['c2CallID'];
		$isPublic = $args['isPublic'];
		$topic = $args['topic'];

		$stmt->execute();
		$stmt->close();

		$stmt = $this->db->conn2->prepare("select id from chatGroup where c2CallID = ?");
		$stmt->bind_param('s', $c2CallID);
		$c2CallID = $args['c2CallID'];
		$stmt->execute();
		$verifyRes = $stmt->get_result();

		$verifyRow = mysqli_fetch_assoc($verifyRes);

		if ($verifyRow['id'] > 0) {
			$groupID = $verifyRow['id'];
			$stmt->close();
			
			//save initial members
			$stmt = $this->db->conn2->prepare("insert into groupMember (groupID, memberID, requestAccepted) values (?, ?, 1)");
			$stmt->bind_param('ss', $pgroupID, $memberID);
			$pgroupID = $groupID;
			for($i = 1; $i <= $args['memberCnt']; $i++){
				$memberID = $args['memberID'.$i];
				$stmt->execute();
			}
			$stmt->close();
			return array('error' => 0, 'message' => 'Insert Successfully', 'id' => $args['memberCnt']);
		} else {
			return array('error' => 1, 'message' => 'Insert failed');
		}
    }
    
    protected function addGroupMember($args){
        if ($args['groupID'] == '' || $args['memberID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');
            
		$stmt = $this->db->conn2->prepare("insert into groupMember (groupID, memberID, requestAccepted) values (?, ?, 1)");
		$stmt->bind_param('ss', $groupID, $memberID);

		$groupID = $args['groupID'];
		$memberID = $args['memberID'];
		$stmt->execute();
				
		return array('error' => 0, 'message' => 'Insert Successfully');
    }
    
    protected function removeGroupMember($args){
        if ($args['groupID'] == '' || $args['memberID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');
            
		$stmt = $this->db->conn2->prepare("delete from groupMember where groupID=? and memberID=?");
		$stmt->bind_param('ss', $groupID, $memberID);

		$groupID = $args['groupID'];
		$memberID = $args['memberID'];
		$stmt->execute();
				
		return array('error' => 0, 'message' => 'Delete Successfully');
    }
    
    protected function requestJoinGroup($args){
        if ($args['groupID'] == '' || $args['memberID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');
            
		$stmt = $this->db->conn2->prepare("insert into groupMember (groupID, memberID, requestAccepted) values (?, ?, 3)");
		$stmt->bind_param('ss', $groupID, $memberID);

		$groupID = $args['groupID'];
		$memberID = $args['memberID'];
		$stmt->execute();
				
				
		$stmt = $this->db->conn2->prepare("select groupAdmin, topic from chatGroup where id = ?");
		$stmt->bind_param('s', $groupID);
		$groupID = $args['groupID'];
		$stmt->execute();
		$verifyRes = $stmt->get_result();

        $verifyRow = mysqli_fetch_assoc($verifyRes);


        if ($verifyRow['groupAdmin'] != '') {
			$ap = new Apsn();
			$customVals = array(
					'type' => 'join request',
				);
			$message = $args['userName']." wish to join you group ".$verifyRow['topic'];
			$err = $ap->sendNotification($verifyRow['groupAdmin'], $message, $customVals);
		}
				
		return array('error' => 0, 'message' => 'Insert Successfully');
    }
    

	protected function readUserGroups($args){
        if ($args['userID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');


		$stmt = $this->db->conn2->prepare("select chatGroup.id, chatGroup.c2CallID, chatGroup.interestID, chatGroup.interestDescription, chatGroup.topicDescription, chatGroup.locationName, memb.memberCnt, "
											."chatGroup.isPublic, groupMember.requestAccepted, chatGroup.groupAdmin, chatGroup.topic, chatGroup.locationLag, chatGroup.locationLong, register.userName from chatGroup "
											."inner join register on register.msisdn = chatGroup.groupAdmin "
											."left join groupMember on chatGroup.id = groupMember.groupID and groupMember.memberID = ? "
											."left join (select groupID, count(*) as memberCnt from groupMember where requestAccepted = 1 group by groupID) memb on chatGroup.id = memb.groupID "
											."where chatGroup.groupAdmin = ? OR exists(select groupID from groupMember where groupID = chatGroup.id and memberID = ?)");

		$stmt->bind_param('sss', $userID, $adminID, $memberID);
        		
		$userID = $args['userID'];
		$adminID = $args['userID'];
		$memberID = $args['userID'];


		$stmt->execute();


		$res = $stmt->get_result();
		$rowCnt = 0;
		$groupArray = array();
		while($row = mysqli_fetch_assoc($res)){
			$groupArray['groupID' . $rowCnt] = $row['id'];
			$groupArray['c2CallID' . $rowCnt] = $row['c2CallID'];
			$groupArray['interestID' . $rowCnt] = $row['interestID'];
			$groupArray['interestDescription' . $rowCnt] = $row['interestDescription'];
			$groupArray['topicDescription' . $rowCnt] = $row['topicDescription'];
			$groupArray['locationName' . $rowCnt] = $row['locationName'];
			$groupArray['memberCnt' . $rowCnt] = $row['memberCnt'];
			$groupArray['isPublic' . $rowCnt] = $row['isPublic'];
			$groupArray['topic' . $rowCnt] = $row['topic'];
			$groupArray['locationLag' . $rowCnt] = $row['locationLag'];
			$groupArray['locationLong' . $rowCnt] = $row['locationLong'];
			$groupArray['userName' . $rowCnt] = $row['userName'];
			
			if($row['groupAdmin'] == $args['userID']){
				$groupArray['isMember' . $rowCnt] = 2;
			}
			else{
				$groupArray['isMember' . $rowCnt] = $row['requestAccepted'];			
			}
			
			$rowCnt++;
		}
		$groupArray['rowCnt'] = $rowCnt;
		$groupArray['error'] = 0;
		$groupArray['message'] = 'Loaded Successfully';
        return $groupArray;
	}
	
	protected function searchGroup($args){
        if ($args['searchString'] == '' || $args['userID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$sqlStr = "select distinct chatGroup.id, chatGroup.c2CallID, chatGroup.interestID, chatGroup.interestDescription, chatGroup.locationLag, chatGroup.locationLong, "
				."chatGroup.topicDescription, chatGroup.locationName, chatGroup.isPublic, groupMember.requestAccepted, chatGroup.groupAdmin, memberCnt, chatGroup.topic, register.userName from chatGroup "
				."inner join register on register.msisdn = chatGroup.groupAdmin "
				."left join groupMember on chatGroup.id = groupMember.groupID AND groupMember.memberID = ? "
				."left join interestBase on chatGroup.interestID = interestBase.interestID "
				."left join interestCat on chatGroup.interestID = interestCat.interestID "
				."left join (select groupID, count(*) as memberCnt from groupMember where requestAccepted = 1 group by groupID) memb on chatGroup.id = memb.groupID "
				."where (chatGroup.topicDescription like ? "
				."OR chatGroup.topic like ? "
				."OR chatGroup.interestDescription like ? "
				."OR interestBase.interestName like ? "
				."OR interestCat.displayText like ? "
				."OR chatGroup.locationName like ?) "
				."AND (chatGroup.locationLag between ? AND ?) "
				."AND (chatGroup.locationLong between ? AND ? "
				."OR chatGroup.locationLong between ? AND ? "
				."OR chatGroup.locationLong between ? AND ?) ";


		$stmt = $this->db->conn2->prepare($sqlStr);

		$stmt->bind_param('sssssssssssssss', $userID, $str1, $str2, $str3, $str4, $str5, $str6, $latFrom, $latTo, $longFrom1, $longTo1, $longFrom2, $longTo2, $longFrom3, $longTo3);      
		$userID = $args['userID'];
		$str1 = "%" . $args['searchString'] . "%";
		$str2 = $str1;
		$str3 = $str1;
		$str4 = $str1;
		$str5 = $str1;
		$str6 = $str1;
		$latFrom = $args['latFrom'];
		$latTo = $args['latTo'];
		$longFrom1 = $args['longFrom'];
		$longTo1 = $args['longTo'];
		$longFrom2 = $args['longFrom'] + 360;
		$longTo2 = $args['longTo'] + 360;
		$longFrom3 = $args['longFrom'] - 360;
		$longTo3 = $args['longTo'] - 360;

		$stmt->execute();


		$res = $stmt->get_result();
		$rowCnt = 0;
		$groupArray = array();
		while($row = mysqli_fetch_assoc($res)){
			$groupArray['groupID' . $rowCnt] = $row['id'];
			$groupArray['c2CallID' . $rowCnt] = $row['c2CallID'];
			$groupArray['interestID' . $rowCnt] = $row['interestID'];
			$groupArray['interestDescription' . $rowCnt] = $row['interestDescription'];
			$groupArray['topicDescription' . $rowCnt] = $row['topicDescription'];
			$groupArray['locationName' . $rowCnt] = $row['locationName'];
			$groupArray['memberCnt' . $rowCnt] = $row['memberCnt'];
			$groupArray['isPublic' . $rowCnt] = $row['isPublic'];
			$groupArray['topic' . $rowCnt] = $row['topic'];
			$groupArray['locationLag' . $rowCnt] = $row['locationLag'];
			$groupArray['locationLong' . $rowCnt] = $row['locationLong'];
			$groupArray['userName' . $rowCnt] = $row['userName'];
			if($row['groupAdmin'] == $args['userID']){
				$groupArray['isMember' . $rowCnt] = 2;
			}
			else{
				$groupArray['isMember' . $rowCnt] = $row['requestAccepted'];			
			}			
			$rowCnt++;
		}
		$groupArray['rowCnt'] = $rowCnt;
		$groupArray['error'] = 0;
		$groupArray['message'] = 'Loaded Successfully';
        return $groupArray;
		
	
	}

    protected function updateGroupInfo($args) {

        if ($args['c2CallID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("update chatGroup set topic = ?, "
											." topicDescription = ?, "
											." interestID = ?, "
											." interestDescription = ?, "
											." locationLag = ?, "
											." locationLong = ?, "
											." locationName = ?, "
											." isPublic = ? "
											." where c2CallID = ?");
		$stmt->bind_param('sssssssss', $topic, $topicDesc, $interestID, $interestDesc, 
							$locLag, $locLong, $locationName, $isPublic, $c2CallID);
		$topic = $args['topic'];
		$topicDesc = $args['topicDescription'];
		$interestID = $args['interestID'];
		$interestDesc = $args['interestDescription'];
		$locLag = $args['locationLag'];
		$locLong = $args['locationLong'];
		$locationName = $args['locationName'];
		$isPublic = $args['isPublic'];
		$c2CallID = $args['c2CallID'];
		$stmt->execute();
		$stmt->close();
		return array('error' => 0, 'message' => 'Group updated');
    }


	protected function readOutStandingRequest($args){
        if ($args['userID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');


		$stmt = $this->db->conn2->prepare("select chatGroup.id, chatGroup.c2CallID AS groupC2CallID, chatGroup.topic, "
											."register.msisdn, register.c2CallID, register.userName, register.interestID, register.interestDescription, register.dob, register.gender from chatGroup "
											."inner join groupMember on chatGroup.id = groupMember.groupID AND groupMember.requestAccepted = 3 "
											."inner join register on groupMember.memberID = register.msisdn "
											."where chatGroup.groupAdmin = ? ");

		$stmt->bind_param('s', $userID);
        		
		$userID = $args['userID'];

		$stmt->execute();


		$res = $stmt->get_result();
		$rowCnt = 0;
		$groupArray = array();
		while($row = mysqli_fetch_assoc($res)){
			$groupArray['groupID' . $rowCnt] = $row['id'];
			$groupArray['groupC2CallID' . $rowCnt] = $row['groupC2CallID'];
			$groupArray['topic' . $rowCnt] = $row['topic'];
			$groupArray['msisdn' . $rowCnt] = $row['msisdn'];
			$groupArray['c2CallID' . $rowCnt] = $row['c2CallID'];
			$groupArray['userName' . $rowCnt] = $row['userName'];
			$groupArray['interestID' . $rowCnt] = $row['interestID'];
			$groupArray['interestDescription' . $rowCnt] = $row['interestDescription'];
			$groupArray['dob' . $rowCnt] = $row['dob'];
			$groupArray['gender' . $rowCnt] = $row['gender'];
						
			$rowCnt++;
		}
		$groupArray['rowCnt'] = $rowCnt;
		$groupArray['error'] = 0;
		$groupArray['message'] = 'Loaded Successfully';
        return $groupArray;
	}
	
	protected function readOutStandingCount($args){
        if ($args['userID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');


		$stmt = $this->db->conn2->prepare("select count(*) as requestCnt from chatGroup "
											."inner join groupMember on chatGroup.id = groupMember.groupID AND groupMember.requestAccepted = 3 "
											."inner join register on groupMember.memberID = register.msisdn "
											."where chatGroup.groupAdmin = ? ");

		$stmt->bind_param('s', $userID);
        		
		$userID = $args['userID'];

		$stmt->execute();


		$res = $stmt->get_result();
		$groupArray = array();
		if($row = mysqli_fetch_assoc($res)){
			$groupArray['requestCnt'] = $row['requestCnt'];
		}
		$groupArray['error'] = 0;
		$groupArray['message'] = 'Loaded Successfully';
        return $groupArray;
	}
	

	protected function acceptRequest($args){
        if ($args['userID'] == '' || $args['groupID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');
	
		$stmt = $this->db->conn2->prepare("update groupMember set requestAccepted = 1 where groupID = ? and memberID = ?");
		$stmt->bind_param('ss', $groupID, $userId);
		$groupID = $args['groupID'];
		$userId = $args['userID'];
		$stmt->execute();
		$stmt->close();
		return array('error' => 0, 'message' => 'Request Accepted Successfully');
	}
	
	protected function rejectRequest($args){
        if ($args['userID'] == '' || $args['groupID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');
	
		$stmt = $this->db->conn2->prepare("update groupMember set requestAccepted = 4 where groupID = ? and memberID = ?");
		$stmt->bind_param('ss', $groupID, $userId);
		$groupID = $args['groupID'];
		$userId = $args['userID'];
		$stmt->execute();
		$stmt->close();
		return array('error' => 0, 'message' => 'Request Rejected Successfully');
	}
	
    protected function readGroupInfo($args) {

        if ($args['c2CallID'] == '' || $args['userID'] == '')
            return array('error' => 1, 'message' => 'Mandatory field missing');

		$stmt = $this->db->conn2->prepare("select chatGroup.id, chatGroup.c2CallID, chatGroup.interestID, chatGroup.interestDescription, chatGroup.topicDescription, chatGroup.locationName, memb.memberCnt, "
											."chatGroup.isPublic, groupMember.requestAccepted, chatGroup.groupAdmin, chatGroup.topic, chatGroup.locationLag, chatGroup.locationLong, register.userName from chatGroup "
											."inner join register on register.msisdn = chatGroup.groupAdmin "
											."left join groupMember on chatGroup.id = groupMember.groupID and groupMember.memberID = ? "
											."left join (select groupID, count(*) as memberCnt from groupMember where requestAccepted = 1 group by groupID) memb on chatGroup.id = memb.groupID "
											."where chatGroup.c2CallID = ?");

		$stmt->bind_param('ss', $userID, $c2CallID);
		$userID = $args['userID'];
		$c2CallID = $args['c2CallID'];
		$stmt->execute();
		$verifyRes = $stmt->get_result();

        $verifyRow = mysqli_fetch_assoc($verifyRes);

        if ($verifyRow['c2CallID'] == $args['c2CallID']) {
        
			$groupArray = array();
			$groupArray['groupID'] = $verifyRow['id'];
			$groupArray['c2CallID'] = $verifyRow['c2CallID'];
			$groupArray['interestID'] = $verifyRow['interestID'];
			$groupArray['interestDescription'] = $verifyRow['interestDescription'];
			$groupArray['topicDescription'] = $verifyRow['topicDescription'];
			$groupArray['locationName'] = $verifyRow['locationName'];
			$groupArray['memberCnt'] = $verifyRow['memberCnt'];
			$groupArray['isPublic'] = $verifyRow['isPublic'];
			$groupArray['topic'] = $verifyRow['topic'];
			$groupArray['locationLag'] = $verifyRow['locationLag'];
			$groupArray['locationLong'] = $verifyRow['locationLong'];
			$groupArray['userName'] = $verifyRow['userName'];
			if($row['groupAdmin'] == $args['userID']){
				$groupArray['isMember'] = 2;
			}
			else{
				$groupArray['isMember'] = $verifyRow['requestAccepted'];			
			}	
			$groupArray['error'] = 0;
			$groupArray['resultCode'] = 1;
			$groupArray['message'] = 'Loaded Successfully';
	        return $groupArray;
			
        } else {
            return array('error' => 1, 'message' => 'Read failed', 'resultCode' => 0);
        }
    }
    
    

    protected function readInterest($args) {

        if ($args['lang'] == ''){
			$stmt = $this->db->conn2->prepare("select interestID, interestName from interestBase ");
		}
		else{
			$sql = "select b.interestID, b.interestName, c.displayText "
					."from interestBase b left join interestCat c ON b.interestID = c.interestID AND c.languageCode = ?"; 
			$stmt = $this->db->conn2->prepare($sql);
			$stmt->bind_param('s', $lang);
			$lang = $args['lang'];		
		}
		$stmt->execute();
		$res = $stmt->get_result();
		$rowCnt = 0;
		$interestArray = array();
		while($row = mysqli_fetch_assoc($res)){
			$interestArray['id' . $rowCnt] = $row['interestID'];
			if($args['lang'] == ''){
				$interestArray['name' . $rowCnt] = $row['interestName'];
			}
			else if($row['displayText'] == ''){
				$interestArray['name' . $rowCnt] = $row['interestName'];
			}
			else{
				$interestArray['name' . $rowCnt] = $row['displayText'];
			}
			$rowCnt++;
		}
		$interestArray['rowCnt'] = $rowCnt;
		$interestArray['error'] = 0;
		$interestArray['message'] = 'Verified Successfully';
        return $interestArray;
    }
    
    protected function addressBookCheck($args) {
		$phoneCnt = $args['PhoneCnt'];

		$stmt = $this->db->conn2->prepare("select c2CallID from register where email = ?");
		$stmt->bind_param('s', $email);
		
		$resArray = array();
		for($i = 0; $i < $phoneCnt; $i++){
			$email = $args['PHONE'.i].'@mobifyi.com';
			$stmt->execute();
			$res = $stmt->get_result();
        	$row = mysqli_fetch_assoc($verifyRes);
			$resArray['id' . $i] = $row['c2CallID'];
		}
		
		$resArray['rowCnt'] = $i;
		$resArray['error'] = 0;
		$resArray['message'] = 'Verified Successfully';
        return $resArray;
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