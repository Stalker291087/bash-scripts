#!/bin/bash 

###################################################################
#Script Name	: mongodb_backup.sh                                                                                              
#Description	: Purpose of the script is to be run via cronjob to backup the MongoDB atlas database                                                                              
#Args           : None
#Last Modified  : Friday, Jul 14, 2023                                                                                             
#Author       	: Jean C Espinoza                                          
#Email         	: jeancarloe01@hotmail.com                               
###################################################################

FILE="/home/ec2-user/automation/.mongo.txt"
userName="$(cut -d: -f 2 $FILE | head -1)"
password="$(cut -d: -f 2 $FILE | tail -1)"
log_file='/home/ec2-user/automation/logs/mongodb_backup.log'
date=date=$( date )
fileName=$( date +%F )
backup_directory='/home/ec2-user/mongodb_dumpfiles'
s3_bucket='<>'
slack_webhook='<>'

echo "####################################################" >> ${log_file}
echo "Starting DUMP of MongoDB atlas at ${date}" >> ${log_file}
curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, Starting DUMP of MongoDB atlas!"}' $slack_webhook
mongodump --uri mongodb+srv://$userName:$password@cemd-cluster.kqnkimj.mongodb.net/appsmith -o $backup_directory >> ${log_file}
if [ "$?" -eq 0 ]; then
    echo "DUMP completed at ${date}" >> ${log_file}
    echo "Zipping file ..." >> ${log_file}
    zip -qr $backup_directory/${fileName}.zip $backup_directory/*
    echo "Uploading zip file to S3 ..." >> ${log_file}
    aws s3 sync ${backup_directory} $s3_bucket --exclude "*" --include "*.zip" >> ${log_file}
    if [ "$?" -eq 0 ]; then
        echo "Backup file uploaded to S3 ..." >> ${log_file}
        echo "####################################################" >> ${log_file}
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, MongoDB Atlas dump has succeeded!"}' $slack_webhook
        find $backup_directory -name *.zip -delete
        cd $backup_directory
        rm -dfr *
    fi
else
    echo "DUMP failed at ${date}" >> ${log_file}
    echo "####################################################" >> ${log_file}
    curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, MongoDB Atlas dump has failed, check the logs!"}' $slack_webhook
fi
