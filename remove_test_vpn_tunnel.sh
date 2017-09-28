#!/bin/bash

#!/bin/bash
if [ -z "$1" ]
  then
    echo "No container number supplied"
    exit
fi



ansible-playbook  -i ./inventory   remove_vpn_tunnel.yml -e "_cluster_id=100000 _cluster_name=bigbear _node_number=$1 _node_name=sirius"