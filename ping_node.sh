#!/bin/bash

#!/bin/bash
if [ -z "$1" ]
  then
    echo "No ip address supplied"
    exit
fi



ansible-playbook  -i ./inventory   ping_node.yml -e "_node_ip6_address=$1"