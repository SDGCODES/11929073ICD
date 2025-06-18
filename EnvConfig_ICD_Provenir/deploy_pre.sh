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
echo "#deploy pre"

echo "> Set timezone"
timedatectl set-timezone Europe/London

echo "> yum install packages"
sudo yum install -y git jq pcre cloud-utils-growpart

echo "> resize disk"
growpart /dev/sda 2
pvresize /dev/sda2
lvresize -r -l +50%FREE /dev/mapper/vg00-lv_var_tmp
lvresize -r -l +100%FREE /dev/mapper/vg00-lv_var_log
mount -o remount, size=30G /tmp/
lvextend -L+30G /dev/vg00/lv_opt

echo "# deploy pre complete"


	
		