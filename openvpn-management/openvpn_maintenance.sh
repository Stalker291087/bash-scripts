#!/bin/bash

###################################################################
#Script Name    : openvpn_service_maintenance.sh
#Description    : Purpose of the script is to restart the openvpn service
#Args           : None
#Prerequisites  : None
#Last Modified  : Thursday, June 1st, 2023  
#Author         : Jean C Espinoza
#Email          : jeancarloe01@hotmail.com
###################################################################

#variables
echo -n "Enter the action you require, valid options are status, stop, start, restart: "
read action
openvpn_status=$( systemctl status openvpn | grep active | wc -l)

if [ "$action" == "status" || "$action" == "stop" || "$action" == "start" || "$action" == "restart" ]; then
    if [ "$action" == "status"]; then
        echo "OpenVPN  -" $(systemctl status openvpn | grep 'active\|inactive')
    elif [ "$openvpn_status" -eq 1 || "$action" == "stop" ]; then
        systemctl stop openvpn
    elif [ "$openvpn_status" -eq 0 || "$action" == "start" ]; then
        systemctl start openvpn
        echo "OpenVPN  -" $(systemctl status openvpn | grep 'active\|inactive')
    elif [ "$openvpn_status" -eq 0 || "$action" == "restart" ]; then
        systemctl restart openvpn
        echo "OpenVPN  -" $(systemctl status openvpn | grep 'active\|inactive')
else
    echo "Valid options are status, stop, start, restart. please try again"
fi
