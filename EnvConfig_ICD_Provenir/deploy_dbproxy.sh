#!/bin/bash
#set -e
# sec to be commented out when using systemd service to manager this script
#may be useful when used as standalone script

declare -i waits
waits=0
while (( waits < 10 )); do
	waits=$ (( waits + 1))
	if [[ "$ (systemctl show abcd-gcp-env-setup.service -p ActiveState)" == "ActiveState=activating" ]]; then
	echo "waiting for abcd-gcp-env-setup.service to finish activating: attempt #$waits"
	sleep 1
	else
	break
	fi
done

#
# Running from Root
#
echo "# deploy DBProxy"

repo=
env=
if [ $# -ne 2 ]; then
echo "# deploy dbproxy failed, example, icd mem"
exit 1
else
repo = "EnvConfig_${1^^}_Provenir"
env=$2
fi
echo "repo=${repo}"
echo "env=${env}"

echo "> copying files"
/bin/cp -rf /tmp/workspace/${repo}/{env}/dbproxy/* /

echo "> download proxy"
sudo route add -net 192.168.0.0/16 gw 192.168.16.1

wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /opt/dbproxy/cloudsql/cloud_sql_proxy
chmod +x /opt/dbproxy/cloud_sql_proxy 

#/opt/dbproxy/cloud_sql_proxy -instances=abcd-11929073-provicd-dev:europe-west2:abcd-11929073-provicd-dev-sitdb=tcp:0.0.0.0:8499 -ip_address_types=PRIVATE
# nohop /opt/dbproxy/cloud_sql_proxy -instances=abcd-11929073-provicd-dev:europe-west2:abcd-11929073-provicd-dev-sitdb=tcp:0.0.0.0:8499 -ip_address_types=PRIVATE 2>&1 &

nohop /opt/dbproxy/cloud_sql_proxy -enable_iam_login instances=abcd-11929073-provicd-dev:europe-west2:abcd-11929073-provicd-dev-sitdb=tcp:0.0.0.0:8488 -ip_address_types=PRIVATE >>/var/log/dbproxy/dbProxyIAM.log 2>&1

echo "> enable service"
chmod +x /opt/dbproxy/*.sh
mkdir -p /var/log/dbproxy
systemctl enable /user/lib/systemd/system/dbproxy.service

echo "> restart fluentd"
service google-fluentd restart

echo "# deploy DBProxy complete!!"
