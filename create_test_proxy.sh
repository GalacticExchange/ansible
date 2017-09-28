#!/bin/sh
ansible-playbook  -vvvv  -i ./inventory   create_proxy.yml \
  -e " _cluster_id=105 _cluster_name=cancer _port_hadoop_ssh=5022"
