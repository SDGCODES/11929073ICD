#!bin/bash
#set -e


# section to be commented out when using systemd service to manage this script
# may be useful when used as standalone script
declare -i waits
waits=0
while (( waits < 10 ));do
	waits=$(( waits + 1 ))
	if [[ "$(systemctl show hsbc-gcp-env-setup.service -p ActiveState)" == "ActiveState=activating" ]]; then
		echo "waiting for hsbc-gcp-env-setup.service to finish activating: attempt #$waits"
		sleep 1
	else
		break
	fi
done

#
# Running from root
#
echo "# deploy provenir"

repo=
env=
action=
if [ $# -ne 3 ]; then
	echo "# param error"
	exit 1
else	
	repo="EnvConfig_${1^^}_Terraform"
	env=$2
	action=$3
fi
echo "repo=${repo}"
echo "env=${env}"
echo "action=${action}"


echo "> building"
cd ${HOME}/provenir/${repo}/${env}/provenir-image
${HOME}/provenir/terraform/terraform init -no-color

if [[ ${action} == "destroy" ]]; then
	${HOME}/provenir/terraform/terraform plan -destroy -no-color
else 
	${HOME}/provenir/terraform/terraform plan -no-color
fi
${HOME}/provenir/terraform/terraform ${action} -auto-approve -no-color

echo "> complete"