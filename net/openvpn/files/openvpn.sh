#!/bin/sh
cip=`uci get openvpn.sample_client.cip`
myfile1=`cat /lib/uci/upload/cbid.openvpn.fullconfig|grep "up /"`
myfile2=`cat /lib/uci/upload/cbid.openvpn.fullconfig|grep "down /" `
if [ "$myfile1" != "" ];then
     path1=`echo $myfile1|awk '{print $2}'`
     touch $path1
     chmod +x $path1
     echo "#!/bin/sh" > $path1
     echo "ifconfig \$1 $cip netmask \$5">> $path1
     echo "/etc/init.d/openvpnroute restart" >> $path1
fi
if [ "$myfile2" != "" ];then
     path2=`echo $myfile2|awk '{print $2}'`
     touch $path2
     chmod +x $path2
     echo "#!/bin/sh" > $path2
     echo "date > /tmp/openvpn_down" >> $path2
     echo "/etc/init.d/openvpnroute stop" >> $path2
fi

