#!/bin/bash 

###################################################################
#Script Name    : efs_backup_from_ec2.sh                                                                                          
#Description    : This script is to mount the EFS file system into the EC2 instance and then sync the contantent to a S3 bucket. Needs to be run as sudo or from the root crontab.                                                                    
#Args           : None
#Last Modified  : Thursday, May 18, 2023                                                                                    
#Author         : Jean C Espinoza                                       
#Email          : jeancarloe01@hotmail.com                                
###################################################################

# variables
date=$( date )
fileName=$( date +%F )
no_files=$( ls -al /home/ec2-user/app_smith_efs | wc -l )
efs_filesystem='<>'
local_mount_point='/home/ec2-user/app_smith_efs'
s3_bucket='<>'
log_file='/home/ec2-user/automation/logs/appsmith_fs_backup.log'
slack_webhook='<>'

# Mounting the EFS file system into /home/ec2-user/app_smith_efs 
if [ "$no_files" -lt 5 ]; then 
    sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $efs_filesystem   $local_mount_point
# Zip the files and sync the mount point with the S3 bucket.
    if [ "$?" -eq 0 ]; then
        zip -qr $local_mount_point/${fileName}.zip $local_mount_point/*
        aws s3 sync ${local_mount_point} $s3_bucket --exclude "*" --include "*.zip" >> ${log_file}
        find $local_mount_point -name *.zip -delete
        if [ "$?" -eq 0 ]; then
            echo "Backup of Appsmight EFS has been completed without any issues at ${date}." >> ${log_file}
            curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, OpenVPN backup has executed correctly!"}' $slack_webhook
        else
            echo "There was an error backing up the file system at ${date}, make the required corrections and try again." >> ${log_file}
            curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, There was an error backing up the file system, make the required corrections and try again!"}' $slack_webhook
        fi      
    else
        echo "Error when mounting the file system at ${date}, check EFS DNS name or the local directory where the file system is being mounted" >> ${log_file}
    fi
else
    zip -qr $local_mount_point/${fileName}.zip $local_mount_point/*
    aws s3 sync $local_mount_point $s3_bucket --exclude "*" --include "*.zip" >> ${log_file}
    find $local_mount_point -name *.zip -delete
    if [ "$?" -eq 0 ]; then
        echo "Backup of Appsmight EFS has been completed without any issues at ${date}." >> ${log_file}
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, OpenVPN backup has executed correctly!"}' $slack_webhook
    else
        echo "There was an error backing up the file system at ${date}, make the required corrections and try again." >> ${log_file}
        curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, There was an error backing up the file system, make the required corrections and try again!"}' $slack_webhook
        
    fi 
fi     
