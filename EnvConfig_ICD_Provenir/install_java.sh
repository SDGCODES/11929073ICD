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

echo "# deploy java"

echo "> downlaod java"
gsutil cp gs://abcd-12214544-provuk-dev/Java/jdk-8u231-linux-x64.tar.gz tmp/jdk-8u231-linux-x64.tar.gz

echo ">unzip java"
tar zxvf /tmp/jdk-8u231-linux-x64.tar.gz -C /opt/
mv /opt/jdk-8.0.231 /opt/java
chown -R root:root /opt/java
chmod _R a+rwx /opt/java

echo "> create link"
ln -s /opt/java/bin/java  /usr/bin/jaba

echo "#deploy java complete