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
echo "installing provenir Admin Console"
source /etc/profile

if [! -d "/opt/provenir70"]; then
cd /tmp
echo "downloading...."
gsutil cp gs://abcd-12214544-provuk-dev/Provenir_v9.5.8.1/Provenir_Admin_Server_64Bit.bin ./

chmod +x *.bin
echo "installing...."
./Provenir_Admin_Server_64Bit.bin -i silent

chown -R provenir:provenir /opt/provenir70/

chkconfig --add prov7adm
else
	echo "Provenir admin console already installed!"
fi
rm -rf /tmp/Provenir*

echo "Provenir admin console installation completed!!"