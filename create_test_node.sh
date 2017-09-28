#!/bin/bash
if [ -z "$1" ]
  then
    echo "No container number supplied"
    exit
fi

ansible-playbook  -vvvv  -i ./inventory   create_node.yml \
  -e "_hadoop_master_ipv4=51.0.1.31 _node_uid=12345678 _cluster_uid=0987654321 _cluster_id=110 _cluster_name=bigbear _node_number=$1 _node_ip6_address=FDE9:E9:E9:3:1:5:0:0/64 _openvpn_ip_address=51.1.0.1 _node_port=525${1} _node_name=sirius _openvpn_ip6_address=FD9E:9E:9E:0:0:1:8:0/64"
