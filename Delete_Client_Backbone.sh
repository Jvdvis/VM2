#!/bin/bash
envdir=/home/Vagrant/VM2/klanten

echo "In this script you will delete a environment of a client"
sleep 1
echo "Name the client:"
read client_name
echo "This client has the following environments active at this moment:"
sleep 1
(cd /$envdir/$client_name/ ; ls)
echo ""
echo "Delete Test or Production environment?"
read environment_client
echo ""$environment_client" possible environments:"
sleep 1
(cd /$envdir/$client_name/$environment_client ; ls)
echo ""
echo "What environment do you want deleted?"
read environment_count

if [[ $environment_client == Test ]];
then 
    ( cd /$envdir/$client_name/$environment_client/$environment_client$environment_count ; vagrant destroy)
    echo "Vagrant destroy has removed the following: "$environment_client$environment_count""
    ( cd $envdir/$client_name/$environment_client/ ; rm -r Test$environment_count)
    echo "The following directory has been removed: "$environment_client$environment_count""
elif [[ $environment_client == Production ]]
then   
    ( cd /$envdir/$client_name/$environment_client/$environment_client$environment_count ; vagrant destroy)
    echo "Vagrant destroy has removed the following: "$environment_client$environment_count""
    ( cd $envdir/$client_name/$environment_client/ ; rm -r Production$environment_count)
    echo "The following directory has been removed: "$environment_client$environment_count""
else
    echo "Missing environment choice"
fi