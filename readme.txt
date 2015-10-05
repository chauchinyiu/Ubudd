Note for setting up:
1. Install mysql, apache and php on the server.
2. Replace the value of kURL with the server URL in /ios/WhazzUpp/Helper/Webservice/ServiceURL.m.
3. Run sup.sql to create the database and tables in the mysql DBMS.
4. If the database name and login are changed, change the relevant values in /server/Models/ConDB.php.
5. Place the files in the server folder inside the “/var/www/html/” folder on the server.
6. Push Certificates are required for both C2Call and UpBrink. The certificate on the UpBrink server is “/var/www/html/Models/ck.pem”. Please refer to this page for generating the ck.pem file: “http://www.raywenderlich.com/32960/apple-push-notification-services-in-ios-6-tutorial-part-1”. And refer to this page for generating the certificate for C2Call:”https://www.c2call.com/de/sdk-forum/push-notifications-ios.html”. 


Login detail for services running on the server:

Digital Ocean Droplet:
IP Address: 128.199.145.104
Username: root
Password: vfzcspnrscag

Database Management:
URL:http://128.199.145.104/phpmyadmin/index.php
Username:root 
Password:Aea7QnibaB

UpBrink System admin page:
URL:http://128.199.145.104/admin/index.php
Username:admin
Password:apairthird

FTP:
IP address:128.199.145.104
Username:userftp
Password:apairthird
Note:
1. Require restarting the FTP on the server using this command:”sudo service proftpd restart”
2. The files are uploaded to “/home/FTP-shared/upload/“, the actual files is stored in “/var/www/html/”



Login detail for registered accounts 

Digital Ocean:
Username:kvlsam@gmail.com
Password:wipeout

C2Call developer:
URL:https://www.c2call.com/en/developer-area.html
Username:kvlsam@gmail.com
Password:destruction48

Twillio:
URL:https://www.twilio.com
Username:kvlsam@gmail.com
Password:destruction48


