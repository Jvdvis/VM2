#!/bin/bash
envdir=/home/Vagrant/VM2/klanten

#Configure New Client
read -p "Insert the name of the client: " client_name
sleep 1
echo ""

#Check if the client already exists and responding accordingly
if [ ! -d /home/Vagrant/VM2/klanten/$client_name ]; then

	customer=new_client
	echo "This is your first time here $client_name, welcome!"
else
	customer=returning_client
	echo "Always nice to see a familiar face $client_name, welcome back!"
fi
sleep 2
echo ""
echo ""
echo "$client_name, today we will configure your desired backbone."

#Picking desired environment: Test or Production environments
echo "What sort of environment will you need?"
environment_picks=("Test" "Production" "GoBack")

select opt in "${environment_picks[@]}"
do
	case $opt in
		"Test")
			echo "A Test environment, great let's have some fun!"
            environment_client=Test
			break
			;;
		"Production")
			echo "A Production environment, getting serious here are we?"
			environment_client=Production
			break
			;;
		"GoBack")
			break
			;;
		*) echo "Must you try and break the script? Just pick one of the 3 $REPLY";;
	esac
done
sleep 2

echo ""
echo ""
echo ""

#Existing clients getting a new environment, including generation of an extra environment if one already exists
if [ ! -d /$envdir/$client_name/$environment_client ]; then
	environment_count=1
	echo "We have not detected a $environment_client environment, configuring $environment_client$environment_count"
	sleep 1
else
	echo "We have detected an existing $environment_client environment"
	existing_environment=$(ls -l /home/Vagrant/VM2/klanten/$client_name/$environment_client |wc -l)
	environment_count=$(($existing_environment+1))
        echo "This environment was found: $existing_environment"
	echo "Configured new $environment_client environment: $environment_client$environment_count"
	echo ""
	sleep 2
fi

#Using picked variables to create folders
if [ $customer == "new_client" ]; then
	echo "Configuring home directory for you: $client_name"
	mkdir -p $envdir/$client_name
	sleep 1
	echo "Configuring $environment_client environment"
	mkdir -p $envdir/$client_name/$environment_client
	sleep 1
	echo "Configuring $environment_client$environment_count"
	mkdir -p $envdir/$client_name/$environment_client/$environment_client$environment_count
elif [ $customer == "returning_client" ]; then
	echo "Configuring new directories for you: $client_name"
	if [ ! -d $envdir$client_name/$environment_client ]; then
		mkdir -p $envdir/$client_name/$environment_client
		mkdir -p $envdir/$client_name/$environment_client/$environment_client$environment_count
	else
		echo "Environment detected"
		sleep 1
		echo "Configuring new environment: $environment_client$environment_count"
		mkdir -p $envdir/$client_name/$environment_client/$environment_client$environment_count
		sleep 1
	fi
fi

#Vagrantfile configuration
read -p "How many different hosts will we be making? " host_count
sleep 1

#Create hostfiles with known variables
touch $envdir/$client_name/$environment_client/$environment_client$environment_count/cluster
touch $envdir/$client_name/$environment_client/$environment_client$environment_count/hosts
touch $envdir/$client_name/$environment_client/$environment_client$environment_count/webservers
echo "[webservers]" >> $envdir/$client_name/$environment_client/$environment_client$environment_count/webservers
touch $envdir/$client_name/$environment_client/$environment_client$environment_count/loadbalancers
echo "[loadbalancers]" >>$envdir/$client_name/$environment_client/$environment_client$environment_count/loadbalancers
touch $envdir/$client_name/$environment_client/$environment_client$environment_count/databaseservers
echo "[databaseservers]" >>$envdir/$client_name/$environment_client/$environment_client$environment_count/databaseservers
echo "cluster = {" > $envdir/$client_name/$environment_client/$environment_client$environment_count/cluster

#Specify virtual machines for Virtualbox
sleep 1
clear
declare -A specify_vm
for (( vm=1; vm<=$host_count; vm++))
do
	echo "Configure $vm"
	read -p "Specify VM name for virtual machine $vm:" vm_name
    read -p "Specify VirtualBox name for virtual machine $vm:" vb_name 
	read -p "Specify Hostname for $vm:" vm_hostname
	read -p "Specify IP-address for virtual machine $vm:" vm_ip
	read -p "Specify the Role of the virtual machine: web, lb or db?" vm_role
	read -p "Specify memory in mb (512 recomended): " vm_memory

	specify_vm[vmnaam]=$vm_name
	specify_vm[vbnaam]=$vb_name
	specify_vm[vm_hostname]=$vm_hostname
	specify_vm[vm_ip]=$vm_ip
	specify_vm[vm_memory]=$vm_memory
	specify_vm[vm_role]=$vm_role

echo " '$vm_name' => { :ip => '$vm_ip', :mem => $vm_memory }, " >> $envdir/$client_name/$environment_client/$environment_client$environment_count/cluster

# Insert information in created hostfiles created 
if [ $vm_role = "web" ]; then
	echo "$vm_ip ansible_user=vagrant ansible_private_key_file=.vagrant/machines/$vm_name/virtualbox/private_key" >> $envdir/$client_name/$environment_client/$environment_client$environment_count/webservers
elif [ $vm_role = "lb" ]; then
	echo "$vm_ip ansible_user=vagrant ansible_private_key_file=.vagrant/machines/$vm_name/virtualbox/private_key" >> $envdir/$client_name/$environment_client/$environment_client$environment_count/loadbalancers
elif [ $vm_role = "db" ]; then
	echo "$vm_ip ansible_user=vagrant ansible_private_key_file=.vagrant/machines/$vm_name/virtualbox/private_key" >> $envdir/$client_name/$environment_client/$environment_client$environment_count/databaseservers
fi

done

echo " }" >> $envdir/$client_name/$environment_client/$environment_client$environment_count/cluster

#Vagrant and cluster info merge
cp /home/Vagrant/VM2/Vagrantfile $envdir/$client_name/$environment_client/$environment_client$environment_count/templatevagrantfile
cat $envdir/$client_name/$environment_client/$environment_client$environment_count/cluster $envdir/$client_name/$environment_client/$environment_client$environment_count/templatevagrantfile > $envdir/$client_name/$environment_client/$environment_client$environment_count/Vagrantfile

#Merge Role and Hosts
cat $envdir/$client_name/$environment_client/$environment_client$environment_count/webservers $envdir/$client_name/$environment_client/$environment_client$environment_count/loadbalancers $envdir/$client_name/$environment_client/$environment_client$environment_count/databaseservers > $envdir/$client_name/$environment_client/$environment_client$environment_count/hosts

#Copy templates
cp /home/Vagrant/VM2/ansibleplaybooks/infra.yml $envdir/$client_name/$environment_client/$environment_client$environment_count/
cp /home/Vagrant/VM2/ansibleplaybooks/ansible.cfg $envdir/$client_name/$environment_client/$environment_client$environment_count/
cp -r /home/Vagrant/VM2/ansibleplaybooks/roles $envdir/$client_name/$environment_client/$environment_client$environment_count/

#Vagrant up - change owner to vagrant - change directory to chosen client
sudo chown -R vagrant /home/Vagrant
cd $envdir/$client_name/$environment_client/$environment_client$environment_count
vagrant up

clear
sleep 1
echo "Ping Pong testing"

result="fatal"

while [[ $result =~ "fatal" ]]
  do
  result=$(ansible all -m ping)
  echo $result;
done

#Playing playbooks
echo ""
echo "Playing Playbooks, it's been a pleasure doing this with you!"
ansible-playbook infra.yml