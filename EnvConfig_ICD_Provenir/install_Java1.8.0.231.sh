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
echo "installing Java"

if [! -d "/opt/java"]; then
cd /tmp
gsutil cp gs://abcd-12214544-provuk-dev/Java/Java_jdk-8u231-linux-x64.tar ./
tar zxvf /tmp/jdk-8u231-linux-x64.tar
mkdir -p /opt/java
mv jdk1.8.0.231 /opt/java
chmod -R a+rwx /opt/java

else
	echo "java 1.8.0.231 already installed!"
fi
rm -rf /tmp/jdk1.8.0_231*
echo "java 1.8.0.231 installation completed!!"

source /etc/profile