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

export NIC1_GW=$(/bin/curl -s -H 'Metadata-Flavor: Google'
http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/1/gateway | /bin/head -1)

sudo del -net 192.168.0.0/16 gw ${NIC1_GW}

sudo pkill -9 cloud_sql_proxy