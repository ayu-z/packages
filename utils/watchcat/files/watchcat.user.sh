#!/bin/sh

logger 'run watchcat user sh'


ATtool=ylx_AT-Tool
switch=$(uci get watchcat.@watchcat[0].simslot)
vidpid=`cat /sys/kernel/debug/usb/devices |grep Vendor |grep -v "Vendor=1d6b"|head -n 1 |awk  '{print $2  $3}'`
atDev=$(cat /tmp/modem.json |grep atDev |awk -F':' '{print $2}' |tr -d '"", ')
simslot=$(cat /tmp/modem.json |grep SimSlot |awk -F':' '{print $2}' |tr -d '"", ')
[ -z "$simslot"] && simslot='1'
[ -z "$atDev" ] && logger "Fetch device error" && exit 

sendCmd(){
    cmd=$1
    $ATtool -p "$atDev" -c "$cmd"
}

if [ "$switch"x == "1"x ]; then
    case $vidpid in
        Vendor=2deeProdID=4d52)
            if [ "$simslot" == "1" ]; then
                sendCmd "AT^SIMSLOT=2"
                sleep 3
                simstate=$(sendCmd "at+cpin?"|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$simstate" != "READY" ]; then
                    sendCmd "AT^SIMSLOT=1"
                    sendCmd "AT+CFUN=1,1"
                fi
            else
                sendCmd "AT^SIMSLOT=1"
                simstate=$(sendCmd "at+cpin?"|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$simstate" != "READY" ]; then
                    sendCmd "AT^SIMSLOT=2"
                    sendCmd "AT+CFUN=1,1"
                fi
            fi
        ;;
        Vendor=2c7cProdID=0800)
            if [ "$simslot" == "1" ]; then
                sendCmd "AT+QUIMSLOT=2"
                sleep 3
                simstate=$(sendCmd "at+cpin?"|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$simstate" != "READY" ]; then
                    sendCmd "AT+QUIMSLOT=1"
                    sendCmd "AT+CFUN=1,1"
                fi
            else
                sendCmd "AT+QUIMSLOT=1"
                sleep 3
                simstate=$(sendCmd "at+cpin?"|grep CPIN|cut -d" " -f2|tr -d "\r\n")
                if [ "$simstate" != "READY" ]; then
                    sendCmd "AT+QUIMSLOT=2"
                    sendCmd "AT+CFUN=1,1"
                fi
            fi
        ;;
        *)
            sendCmd "AT+CFUN=1,1"
        ;;
    esac
    sleep 5
else
    sendCmd "AT+CFUN=1,1"
fi

