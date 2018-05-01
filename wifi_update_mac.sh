#!/bin/sh

raw="$(/usr/bin/curl -k https://raw.githubusercontent.com/okokgo/mac_list/master/mac_list)"
online_mac_md5="$(echo $raw | md5sum | tr -s '\n') "
old_mac=$(cat mac_md5_list | tr -s '\n')

#68b329da
#69019f3c
old_md5="${old_mac:0:8}"
online_md5="${online_mac_md5:0:8}"
pass_list="68b329da 69019f3c $old_md5"

do_action="True"
for md5 in $pass_list
do
    if [ "$online_md5" == "$md5" ];then
        do_action="False"
    fi
done

echo $online_md5
echo $pass_list
echo $do_action

if [ "$do_action" == "True" ]; then
    echo "update"
    echo $online_mac_md5 > mac_md5_list
    echo $online_mac_md5 >> mac_md5_list_old
    uci set wireless.@wifi-iface[0].encryption=none
    uci set wireless.@wifi-iface[0].ssid=NOPASSWORD
    uci set wireless.@wifi-iface[0].macfilter=allow
    uci set wireless.@wifi-iface[0].macpolicy=allow
    #remove all mac addresses
    uci del wireless.@wifi-iface[0].maclist

    for line in $raw
    do
        MAC=$(echo $line | awk -F"#" '{print $1}')
        uci add_list wireless.@wifi-iface[0].maclist="${MAC}"
        uci commit wireless
        wifi
    done
fi
