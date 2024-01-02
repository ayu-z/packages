#!/bin/sh

logger 'run watchcat user sh'

simslot=$(uci get 4g.modem.simslot)
switch=$(uci get watchcat.@watchcat[0].simslot)
vidpid=`cat /sys/kernel/debug/usb/devices |grep Vendor |grep -v "Vendor=1d6b"|head -n 1 |awk  '{print $2  $3}'`

if [ "$switch" == "1" ]; then
    case $vidpid in
        Vendor=2deeProdID=4d52)
            if [ "$simslot" == "1" ]; then
                at_tool AT^SIMSLOT=2
                sleep 3
                reg_net=$(at_tool at+cpin?|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$reg_net" != "READY" ]; then
                    at_tool AT^SIMSLOT=1
                    at_tool AT+CFUN=1,1
                fi
            else
                at_tool AT^SIMSLOT=1
                reg_net=$(at_tool at+cpin?|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$reg_net" != "READY" ]; then
                    at_tool AT^SIMSLOT=2
                    at_tool AT+CFUN=1,1
                fi
            fi
        ;;
        Vendor=2c7cProdID=0800)
            if [ "$simslot" == "1" ]; then
                at_tool AT+QUIMSLOT=2
                sleep 3
                reg_net=$(at_tool at+cpin?|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$reg_net" != "READY" ]; then
                    at_tool AT+QUIMSLOT=1
                    at_tool AT+CFUN=1,1
                fi
            else
                at_tool AT+QUIMSLOT=1
                sleep 3
                reg_net=$(at_tool at+cpin?|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$reg_net" != "READY" ]; then
                    at_tool AT+QUIMSLOT=2
                    at_tool AT+CFUN=1,1
                fi
            fi
        ;;
        *)
            at_tool AT+CFUN=1,1
        ;;
    esac
    sleep 5
    /etc/modem_info.sh
    /etc/init.d/config4g  restart
else
    at_tool AT+CFUN=1,1
fi

