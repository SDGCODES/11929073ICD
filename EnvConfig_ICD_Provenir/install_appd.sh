#!/bin/bash
#set -e
set -x

#section to be commented out when using systemd service to manage this script
#may be useful when used as standalone script
declare -i waits
waits=0
while (( waits < 10 )); do
	waits=$ (( waits + 1 ))
	if [[ "$(systemctl show abcd-gcp-env-setup.service -p ActiveState)" == "ActiveState=activating" ]]; then
	echo "waiting for abcd-gcp-env-setup.service to finish activating: attempt #$waits"
	sleep 1
 else
	break
 fi
done


echo "# deploy AppD"

env=
if [ $# -ne 1 ]; then
	echo "# param failed, dev/prd"
	exit 1
else
	env=$1
fi
echo "env=${env}"

echo "> downloading AppD"
if [[ "${env}" == "prd" ]]
then
	bash appd_binariesRP_app_machine_agent.sh -u provenir -g provenir -p
else
	bash appd_binariesRP_app_machine_agent.sh -u provenir -g provenir
fi


echo "# install AppD complete"