#!/bin/bash
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

#
# Running from SA_provenir
#]


echo "starting ICD SIT"
source /etc/profile

#Admin Console
service prov7adm starting
sleep 3s

#WebDeployer Console
service prov7dep starting
sleep 3s

#Internal-gateway
/opt/provenir70/script/Internal-gateway/Internal-gateway.sh
sleep 3s

echo "ICD SIT started"