#!/bin/bash 

###################################################################
#Script Name    : generate_certificate.sh                                                                                          
#Description    : Script to generate the certificates and the ovpn profile file for a new client to connect.                                                                
#Args           : None
#Prerequisites  : None
#Last Modified  : Tuesday, Jun 06, 2023                                                                                    
#Author         : Jean C Espinoza                                             
#Email          : jeancarloe01@hotmail.com                       
###################################################################

#variables
echo -n "Enter the name of the client : "
read UNIQUE_CLIENT_SHORT_NAME
slack_webhook='<>'
s3_bucket='<>'

# move to easy-rsa directory and generate the certs
cd /etc/openvpn/easy-rsa
./easyrsa gen-req $UNIQUE_CLIENT_SHORT_NAME nopass
./easyrsa sign-req client $UNIQUE_CLIENT_SHORT_NAME

# verify the generated certificates
SSLverification=$( sudo openssl verify -CAfile pki/ca.crt pki/issued/devops.crt | grep OK | wc -l )

if [ $SSLverification -eq 1 ]; then
    echo "SSL verification succeeded :)"
    cp /etc/openvpn/easy-rsa/pki/issued/$UNIQUE_CLIENT_SHORT_NAME.crt ../client/.
    cp /etc/openvpn/easy-rsa/pki/private/$UNIQUE_CLIENT_SHORT_NAME.key ../client/.
    mkdir /home/ubuntu/$UNIQUE_CLIENT_SHORT_NAME
    cd /etc/openvpn/client
    cp ca.crt $UNIQUE_CLIENT_SHORT_NAME.crt $UNIQUE_CLIENT_SHORT_NAME.key /home/ubuntu/$UNIQUE_CLIENT_SHORT_NAME
    cp /etc/openvpn/ta.key /home/ubuntu/$UNIQUE_CLIENT_SHORT_NAME
    cp /home/ubuntu/.template.ovpn /home/ubuntu/$UNIQUE_CLIENT_SHORT_NAME/$UNIQUE_CLIENT_SHORT_NAME.ovpn
    cd /home/ubuntu/$UNIQUE_CLIENT_SHORT_NAME/
    echo "<ca>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    cat ca.crt >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "</ca>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "<cert>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    cat $UNIQUE_CLIENT_SHORT_NAME.crt >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "</cert>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "<key>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    cat $UNIQUE_CLIENT_SHORT_NAME.key >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "</key>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "key-direction 1" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "<tls-auth>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    cat ta.key >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    echo "</tls-auth>" >> $UNIQUE_CLIENT_SHORT_NAME.ovpn
    cd /home/ubuntu/$UNIQUE_CLIENT_SHORT_NAME/
    aws s3 sync . $s3_bucket --exclude "*" --include "*.ovpn"

    echo "Certificates have been generated suceesfully, they can be located at /home/ubuntu/${UNIQUE_CLIENT_SHORT_NAME}"
    curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, new OpenVPN certificates have been generated successfully! They can be found at s3://cemd-vpn-certificates"}' $slack_webhook
    
else
    echo "SSL verification failed, check the newly generated certificates and try again."
    curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello Admin, no OpenVPN certificates were generated. CHECK and try again!"}' $slack_webhook
fi
