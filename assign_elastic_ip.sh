#script Name    : assign_elastic_ip.sh
#Description    : Script to assign an elastic IP to a EC2 instance.
#Args           : None
#Prerequisites  : aws-cli.
#Last Modified  : Tuesday, May 23, 2023
#Author         : CEMD technology team
#Email          : devops@educationmarkets.org
###################################################################

# variables
INSTANCE_ID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`

aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id <> --allow-reassociation
