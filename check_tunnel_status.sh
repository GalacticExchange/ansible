#!/bin/bash

#!/bin/bash
if [ -z "$2" ]
  then
    echo "No container number or container number supplied"
    exit
fi



ansible-playbook  -i ./inventory   check_tunnel_status.yml -e "_cluster_id=$2 _cluster_name=bigbear _node_number=$1 _node_name=sirius"