#!/bin/bash

range=${1}
device=${2}
ip=10.14.10.1${range}
to_email=cyfun.automation.alerts@ktte.cloud
from_email=jarvis@ktte.cloud

case ${range} in 
                                                                                                    #these are the numbered ranges 01-50
                                                                                                    #ranges need to be added here to exend beyond
                                                                                                    #the original 50
    01 | 02 | 03 | 04 | 05 | 06 | 07 | 08 | 09 | 1[0-9] | 2[0-9] | 3[0-9] | 4[0-9] | 50 )
        case ${device} in
                                                                                                    #device is a bit misleading here
                                                                                                    #a device is a singular device or group
                                                                                                    #the devices variable below defines the individual
                                                                                                    #devices that will be modified during a run
            all | all-rescue | configure | imaging | imaging-laptops | router | router-rescue | switch-left | switch-left-rescue | switch-right | switch-right-rescue | server | tshoot0[1-9]* | tshoot[10-17]* )

            #check console switcher availability
            ping -c 1 -t 3 ${ip} > /dev/null
            case ${?} in
                #switch ping is up
                0)
                    #adjust devices for all groups
                                                                                                    #add addl elif statements for device groups
                                                                                                    #the defined devices are the configs that are 
                                                                                                    #passed into the docker container and run in parallel
                                                                                                    #so multiple devices will run concurrently 
                                                                                                    #monitor the log file to watch progress
                                                                                                    #tail -f /var/log/messages
                    if [ "${device}" == "all" ]; then
                        #devices="laptop, router, server, switch-left, switch-right"
                        devices="all"
                    elif [ "${device}" == "all-rescue" ]; then
                        #devices="laptop, router-rescue, server, switch-left-rescue, switch-right-rescue"
                        devices="all-rescue"
                    elif [[ "${device}" ~= "tshoot" ]]; then
                        devices="${device}-router, ${device}-switch-left, ${device}-switch-right"
                    else
                        devices=${device}
                    fi

                    #loop through devices
                                                                                                    #the devices variable is now split and looped into 
                                                                                                    #the docker container
                    for dev in `echo ${devices} | sed 's/,/\ /g'`; do

                        #send start notification
                        echo -e "Request  : ${device}\nDevice\t : ${dev}\nRange\t : ${range}\nStatus\t : Starting" | /bin/mail -r ${from_email} -s "Starting: Range ${range} Device ${dev} Reversion" ${to_email}

                        echo $dev

                        #create unique name for docker run
                                                                                                    #date_cyfun-cs${range}-${dev} can be seen under
                                                                                                    #docker processes
                                                                                                    #docker ps
                        hostname=`date '+%H.%M.%s'`_cyfun_cs${range}-${dev}

                        #run docker
                                                                                                    #the environmental variables defined -e
                                                                                                    #are passed into the container and processed
                                                                                                    #by /usr/local/sbin/entrypoint.sh
                                                                                                    #the entrypoint script then passes in the 
                        docker                                              \
                            run --rm                                        \
                            --name ${hostname}                              \
                            -e RANGE=cyfun_cs${range}                       \
                            -e DEVICE=${dev}                                \
                            -v /vol/shared/usr/local/sbin:/usr/local/sbin   \
                            -v /vol/shared/usr/local/bin:/usr/local/bin     \
                            -v /vol/shared/usr/local/etc:/usr/local/etc     \
                            -v /vol/shared/usr/local/lib:/usr/local/lib     \
                            sync:1.34

                        #send end notification
                        echo -e "Request  : ${device}\nDevice\t : ${dev}\nRange\t : ${range}\nStatus\t : Complete\n\nSyslog\t : ${hostname}" | /bin/mail -r ${from_email} -s "Complete: Range ${range} Device ${dev} Reversion" ${to_email}

                    done
                    ;;
                    
                    #switch ping is down
                    *)
                        echo Console switch ${ip} is not available, please check network connection.
                    ;;
                esac
            ;;
            *)
                echo Device \(${device}\) is not designated for use by this script
                echo Devices:
                echo ===============================================================================================
                echo -e " all                          Reverts range utilizing full configuration on network"
                echo -e " all-rescue                   Reverts range utilizing rescue configuration on network"
                echo -e " configure                    Reverts network utilizing full configuration on network"
                echo -e " imaging                      Reverts range utilizing rescue configuration on network"
                echo -e "                              and configures network for imaging"
                echo -e " imaging-laptops              Creates imaging task for laptops only"
                echo -e " rescue                       Reverts network utilizing rescue configuration on network"
                echo -e " router                       Reverts router utilizing full configuration"
                echo -e " router-rescue                Reverts router utilizing rescue configuration"
                echo -e " server                       Reverts server to Baseline"
                echo -e " switch-left                  Reverts switch-left utilizing full configuration"
                echo -e " switch-left-rescue           Reverts switch-left utilizing rescue configuration"
                echo -e " switch-right                 Reverts switch-right utilizing full configuration"
                echo -e " switch-right-rescue          Reverts switch-right utilizing rescue configuration"
                echo -e " tshoot01                     Configures range for troubleshoot scenerio 01"
                echo -e " tshoot02                     Configures range for troubleshoot scenerio 02"
                echo -e " tshoot03                     Configures range for troubleshoot scenerio 03"
                echo -e " tshoot04                     Configures range for troubleshoot scenerio 04"
                echo -e " tshoot05                     Configures range for troubleshoot scenerio 05"
                echo -e " tshoot06                     Configures range for troubleshoot scenerio 06"
                echo -e " tshoot07                     Configures range for troubleshoot scenerio 07"
                echo -e " tshoot08                     Configures range for troubleshoot scenerio 08"
                echo -e " tshoot09                     Configures range for troubleshoot scenerio 09"
                echo -e " tshoot10                     Configures range for troubleshoot scenerio 10"
                echo -e " tshoot11                     Configures range for troubleshoot scenerio 11"
            ;;
        esac
    ;;
    *)
        echo Range \(${range}\) is not designated for use by this script
        echo Ranges:
        echo ===============================================================================================
        echo -e " 01-50"
    ;;
esac