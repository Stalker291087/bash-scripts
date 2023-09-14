#!/bin/bash 

###################################################################
#Script Name	  : log_rotation.sh                                                                                              
#Description	  : Purpose of the script is to be run via cronjob to rotate some of the /var/log files                                                                              
#Args           : None
#Last Modified  : Monday, Jun 19, 2023                                                                                             
#Author       	: Jean Carlo Espinoza                                              
#Email         	: jeancarloe01@hotmail.com                                 
###################################################################

date=$( date )
no_gzip_files=$( ls -al /home/ec2-user/automation/log_historical | grep *.gzip | wc -l )
slack_webhook='https://hooks.slack.com/services/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'

echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*" >> /home/ec2-user/automation/logs/log_rotation.log
echo "-- Script ran at ${date} --" >> /home/ec2-user/automation/logs/log_rotation.log
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*" >> /home/ec2-user/automation/logs/log_rotation.log
find /var/log/ -type f \( -name "secure-*" -o -name "messages-*" -o -name "spooler-*" -o -name "fail2ban.log*" -o -name "boot.log-*" -o -name "maillog-*" \) -mtime +10 >> /home/ec2-user/automation/logs/log_rotation.log
find /var/log/ -type f \( -name "secure-*" -o -name "messages-*" -o -name "spooler-*" -o -name "fail2ban.log*" -o -name "boot.log-*" -o -name "maillog-*" \) -mtime +10 -exec gzip {} \;
echo "Moving ${no_gzip_files}"
mv /var/log/*.gz /home/ec2-user/automation/log_historical
find /home/ec2-user/automation/log_historical -type f -mtime +30 -delete
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*" >> /home/ec2-user/automation/logs/log_rotation.log
echo "-- End of execution --" >> /home/ec2-user/automation/logs/log_rotation.log
echo "*-*-*-*-*-*-*-*-*-*-*-*-*-*" >> /home/ec2-user/automation/logs/log_rotation.log
find /home/ec2-user/automation/log/historical -type f -mtime +15 -delete
curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, log rotation script ran successfully on the bastion host. Check /home/ec2-user/automation/logs/log_rotation.log for details!"}' $slack_webhook
# Clear journal of OS to retain only 10 days of data
journalctl --vacuum-time=10d
