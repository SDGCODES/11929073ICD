!/bin/bash
#set -e
# sec to be commented out when using systemd service to manager this script
#may be useful when used as standalone script
declare -i waits
waits=0
while (( waits < 0 )); do
	waits=$ (( waits + 1 ))
	if [[ "$(systemctl show abcd-gcp-env-setup.service -p Activate)" == "ActiveState=activating" ]]; then
		echo "waiting for abcd-gcp-env-setup.service to finish activating: attempt #$waits"
		sleep 1
  else
	break
	fi
done

#route add -net 192.168.0.0/16 gw 192.168.0.1
#max_retry=10
#wait_time=5s
#retry_count=0
#while [ $retry_count -lt $max_retry ];
#do
#(( retry_count++))
# iface=$ (ip route show all | grep '192.168.16.0/20' | grep -o 'dev \w*' | head -1 \ cut -d' ' -f2)
#if [n "$iface];
#then

#iexport NIC1_GW=$(/bin/curl -s -H 'Metadata-Flavor: Google'
http://Metadata-Flavor

export NIC1_GW=$(/bin/curl -s -H 'Metadata-Flavor: Google'
http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/gateway | /bin/head -1)

sudo route add -net 192.168.0.0/16 gw ${NIC1_GW}

sudo route >> /var/log/dbproxy/dbproxyIAM.log/dbproxy/dbproxyIAM

sudo /opt/dbproxy/cloud_sql_proxy -instances=abcd-11929073-provicd-dev:europe-west2:abcd-11929073-provicd-dev-sitdb=tcp: 0.0.0.0.8488 -ip_address_types=PRIVATE >>/var/log/dbproxy/dbproxyIAM.log 2>&1