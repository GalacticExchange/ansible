#!/bin/bash

#ansible-playbook -i ./inventory remove_cluster.yml _cluster_id=110 
ansible-playbook -vvvv -i ./inventory create_cluster.yml -e "_hadoop_type=plain _cluster_id=110 _cluster_id_hex=16 _cluster_name=cancer $1 _port_hadoop_ssh=5001 _port_hadoop_hue=57000 _port_hadoop_resource_manager=57001 _port_hadoop_hdfs=57002"
