#!/bin/bash

###################################################################
#Script Name    : openvpn_backup.sh
#Description    : Purpose of the script is to backup all certificates and ovpn files that have been generated.
#Args           : None
#Prerequisites  : None
#Last Modified  : Friday, May 1st, 2023  
#Author         : CEMD technology team
#Email          : devops@educationmarkets.org
###################################################################

#variables
date=$( date )
fileName=$( date +%F )
openvpn_config_folder='/etc/openvpn'
home_certificates='/home/ubuntu'
s3_bucket='s3://xxx'
log_file='/home/ubuntu/automation/logs/openvpn_backup.log'
slack_webhook='https://hooks.slack.com/services/<>'

# zip the configuration of openvpn and easy-rsa
zip -qr /home/ubuntu/automation/openvpn_config_${fileName}.zip $openvpn_config_folder/*
# zip all certificates located at /home/ubuntu
zip -qr /home/ubuntu/automation/openvpn_certs_${fileName}.zip $home_certificates/*
# sync to s3
aws s3 sync /home/ubuntu/automation/ $s3_bucket --exclude "*" --include "*.zip" >> ${log_file}
if [ "$?" -eq 0 ]; then
    echo *-*-*-*-*--*-*-*-*-*-*-*-*-*-*-* >> ${log_file}
    echo "Backup sucessfull at ${date}" >> ${log_file}
    echo *-*-*-*-*--*-*-*-*-*-*-*-*-*-*-* >> ${log_file}
    find /home/ubuntu/automation/ -name "*.zip" -delete
    curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, OpenVPN backup has executed correctly!"}' $slack_webhook
else
    echo "Backup failed, please check and try once more." >> ${log_file}
    curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, OpenVPN backup has failed!"}' $slack_webhook
fi
