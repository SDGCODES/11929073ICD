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
Running from SA terraform
#


echo "start to build infra"

echo "building infra for dbproxysit"
cd /tmp/workspace/EnvConfig_ICD_Terraform/sit/dbproxysit
~/terraform/terraform init
~/terraform/terraform destroy -auto-approve
~/terraform/terraform apply -auto-approve

echo "building infra for sit"
cd /tmp/workspace/EnvConfig_ICD_Terraform/sit/sit
~/terraform/terraform init
~/terraform/terraform destroy -auto-approve
~/terraform/terraform apply -auto-approve

echo "complete to build infra"
