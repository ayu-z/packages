#!/bin/sh

logger 'run watchcat user sh'

ATtool=ylx_AT-Tool
switch=$(uci get watchcat.@watchcat[0].simslot)
vidpid=`cat /sys/kernel/debug/usb/devices |grep Vendor |grep -v "Vendor=1d6b"|head -n 1 |awk  '{print $2  $3}'`
atDev=$(cat /tmp/modem.json | grep atDev | awk -F':' '{print $2}' | tr -d '" ,\t')
simslot=$(cat /tmp/modem.json |grep SIMSLOT |awk -F':' '{print $2}' | tr -d '" ,\t')
[ -z "$simslot" ] && simslot='slot 1'
[ -z "$atDev" ] && {
    logger "Fetch device error" 
    exit 
}

sendCmd(){
    cmd=$1
    
    [ $cmd == "AT+CFUN=1,1" ] && {
        [ ! -f '/tmp/last_time' ] && {
            echo $(date +%s) > /tmp/last_time
        }
        local_time=$(date +%s)
        last_reboot_time=$(cat /tmp/last_time)
        interval=$(($local_time - $last_reboot_time))
        [ "$interval" -lt 120 ] && exit 0
        echo $local_time > /tmp/last_time
    }

    $ATtool -p "$atDev" -c "$cmd"
}

[ $(cat /tmp/sysinfo/model) != "M21L2S" ] && {
    sendCmd "AT+CFUN=1,1"
    exit 0
}

if [ "$switch"x == "1"x ]; then
    case $vidpid in
        Vendor=2deeProdID=4d52)
            if [ "$simslot"x == "slot 1"x ]; then
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
            if [ "$simslot"x == "slot 1"x ]; then
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
else
    sendCmd "AT+CFUN=1,1"
fi

