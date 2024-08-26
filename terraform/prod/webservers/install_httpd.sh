#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Welcome to ACS730 Project ${prefix}, Group 8! My private IP is $myip</h1>
<h2>Daniel Chiatuiro <br> <h2>Olamide Oladiji</h2>
<br>Built by Terraform!"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
