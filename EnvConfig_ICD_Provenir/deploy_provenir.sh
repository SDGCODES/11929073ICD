#!/bin/bash
#set -e
set -x

#section to be commented out when using systemd service to manage this script
#may be useful when used as standalone script
declare -i waits
waits=0
while (( waits < 10 )); do
	waits=$ (( waits + 1 ))
	if [[ "$(systemctl show hsbc-gcp-env-setup.service -p ActiveState)" == "ActiveState=activating" ]]; then
	echo "waiting for hsbc-gcp-env-setup.service to finish activating: attempt #$waits"
	sleep 1
 else
	break
 fi
done

#
# Running from Root
#
echo "# deploy provenir"

repo=
env=
if [ $# -ne 2 ]; then
echo "# deploy provenir failed, example, icd mem"
exit 1
else
repo = "EnvConfig_${1^^}_Provenir"
env=$2
fi
echo "repo=${repo}"
echo "env=${env}"

chmod a+x /tmp/workspace/${repo}/*.sh

#-------------------------------------------

echo "> install java"
/tmp/workspace/${repo}/install_java.sh

#----------------------------------------------

echo "> create provenir user as system account"
useradd -rm provenir

#-------------------------------------------

echo "> install prov9581 admin"
/tmp/workspace/${repo}/install_Prov_AdminConsole.sh

#---------------------------------------------

echo "> install prov9581 web"
/tmp/workspace/${repo}/install_Prov_WebDeployerConsole.sh

#--------------------------------------------------

echo "> install appd"
/tmp/workspace/${repo}/install_appd.sh ${env}

#-------------------------------------------------

echo "> remove files"
rm -rf /opt/provenir70/lib/external/bcprov-jdk16-146.jar

#----------------------------------------------------

echo "> copying files"
/bin/cp -rf /tmp/workspace/${repo}/${env}/provenir/* /

#------------------------------------------------

echo "> apply provenir hot fix for IAM user DB login"
chmod a+x /opt/provenir70/script/provenir_hotfix.sh
ls -ltrh/opt/provenir70/script
/opt/provenir70/script/provenir_hotfix.sh

#------------------------------------------------

echo "> change owner"
chown -R a+rwx /opt/provenir70/opt/java

#--------------------------------------------

echo "> enable prov7 service"
if cat /etc/rc.d/rc.local | grep 'prov7' ; then
echo "already enabled"
else
echo "service prov7dep restart" >> /etc/rc.d/rc.local
echo "sleep 30" >> /etc/rc.d/rc.local
echo "service prov7adm restart" >> /etc/rc.d/rc.local
chmod 775 >> /etc/rc.d/rc.local

fi

#-------------------------------------------

echo "> config house_clean_service"

#--------------------------------------------

echo "> config internal_gateway"
systemctl enable /usr/lib/systemd/system/internal_gateway.service

echo "> config UAE-internal_gateway"
systemctl enable /usr/lib/systemd/system/UAE-internal_gateway.service

#-------------------------------------------

echo "> config symmetric_key_generate service

#---------------------------------------------

echo ">restart fluentd"
service google-fluentd restarty

echo "# deploy provenir completed"
























