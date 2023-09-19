#!/bin/bash 

###################################################################
#Script Name    : prometheus_service_stop.sh                                                                                          
#Description    : Script to restart Prometheus service                                                                  
#Args           : None
#Prerequisites  : None
#Last Modified  : Tuesday, May 23, 2023                                                                                    
#Author         : Jean C Espinoza                                            
#Email          : jeancarloe01@hotmail.com                             
###################################################################

#variables

echo -n "Enter the service name, valid options are prometheus, influxdb, telegraf , blackbox (prometheus module) or all: "
read service_name

#service_status=$( sudo systemctl status $service_name | grep active | wc -l )

if [[ $service_name == "prometheus" || $service_name == "influxdb" ||  $service_name == "telegraf" || $service_name == "blackbox" || $service_name == "all" ]]; then
    echo -n "Enter the required action, valid options are stop, start, status, restart: "
    read ACTION

    case $ACTION in

        stop | STOP)
            if [ "$service_name" != "all" ]; then
                echo "About to stop $service_name ..."
                sudo systemctl stop $service_name
            else
                echo "$service_name is not currently in active state"
            fi

            if [ "$service_name" == "all" ]; then
                echo "About to stop all monitoring services ..."
                sudo systemctl stop telegraf
                sudo systemctl stop influxdb
                sudo systemctl stop blackbox
                sudo systemctl stop prometheus
                sleep 10s
                echo "All services are currently stopped"
                echo "Prometheus -" $(sudo systemctl status prometheus | grep 'active\|inactive')
                echo "InfluxDB -" $(sudo systemctl status influxdb | grep 'active\|inactive')
                echo "Blackbox-Exporter -" $(sudo systemctl status blackbox | grep 'active\|inactive')
                echo "Telegraf -" $(sudo systemctl status telegraf | grep 'active\|inactive')
            fi
            ;;
    
        start | START)
            if [ "$service_name" != "all" ]; then
                echo "About to start $service_name ..."
                sudo systemctl start $service_name
                echo "Service $service_name has been started"
                if [ "$?" -eq 0 ]; then
                    echo "$service_name - " $(sudo systemctl status $service_name | grep 'active\|inactive')
                fi
            else
                echo "$service_name is already in active state"
            fi
            if [ "$service_name" == "all" ]; then
                echo "About to start all monitoring services ..."
                sudo systemctl start influxdb
                sudo systemctl start prometheus
                sudo systemctl start blackbox
                sudo systemctl start telegraf
                echo "All monitoring services are up and running"
            fi            
            ;;

        status | STATUS)
            if [ "$service_name" == "all" ]; then
                echo "Prometheus -" $(sudo systemctl status prometheus | grep 'active\|inactive')
                echo "InfluxDB -" $(sudo systemctl status influxdb | grep 'active\|inactive')
                echo "Blackbox-Exporter -" $(sudo systemctl status blackbox | grep 'active\|inactive')
                echo "Telegraf -" $(sudo systemctl status telegraf | grep 'active\|inactive')
            fi
            if [ "$service_name" != "all" ]; then
                echo "$service_name - " $(sudo systemctl status $service_name | grep 'active\|inactive')
            fi
            ;;
    
        restart | RESTART)
            if [ "$service_name" != "all" ]; then
                echo "About to restart $service_name ..."
                sudo systemctl stop $service_name
                sleep 10s
                sudo systemctl start $service_name
                if [ "$?" -eq 0 ]; then
                    echo "$service_name - " $(sudo systemctl status $service_name | grep 'active\|inactive')
                fi
            else
                echo "$service_name is not currently in active state and cannot be restarted."
            fi
            if [ "$service_name" == "all" ]; then
                echo "About to stop all monitoring services ..."
                sudo systemctl stop telegraf
                sudo systemctl stop influxdb
                sudo systemctl stop blackbox
                sudo systemctl stop prometheus
                sleep 10s
                sudo systemctl start influxdb
                sudo systemctl start telegraf
                sudo systemctl start blackbox
                sudo systemctl start prometheus
                echo "All services are up and running"
            fi
            ;;
        *)
            echo -n "Unknow command, please try again using stop, start or restart."
            ;;
    esac
else
    echo "Please type a valid service name, values are prometheus, influxdb, telegraf."
fi
