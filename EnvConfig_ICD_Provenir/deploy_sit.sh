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
# Running from SA_Provenir
#
echo "deploy SIT"
source /etc/profile

#Resize Disk
yum install -y cloud-utils-growpart
growpart /dev/sda 2
pvresize /dev/sda2
lvresize -r -L +8G /dev/mapper/vg00-lv_var_tmp
lvresize -r -l +50%FREE /dev/mapper/vg00-lv_var_opt
lvresize -r -l +100%FREE /dev/mapper/vg00-lv_var_log

#To install modules
chmod a+x /tmp/workspace/EnvConfig_ICD_Provenir/*.sh
/tmp/workspace/EnvConfig_ICD_Provenir/install_Java1.8.0.231.sh
/tmp/workspace/EnvConfig_ICD_Provenir/install_Prov_AdminConsole.sh
/tmp/workspace/EnvConfig_ICD_Provenir/install_WebDeployerConsole.sh

# To install modules
chmod a+x /tmp/workspace/EnvConfig_ICD_Provenir/sit/sit2/* /
chown -R provenir:provenir /opt/provenir70
chown -R root:root /opt/java
chmod -R a+rwx /opt/provenir70
chmod -R a+rwx /opt/java
rm -rf /opt/provenir70/lib/external/bcprov-jdk16-146.jar
mount -o remound, size=30G /tmp/workspace/EnvConfig_ICD_Provenir/*

echo "ICD SIT installation Completed!!"
