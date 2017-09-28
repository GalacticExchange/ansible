#!/bin/bash
ansible-playbook -vvvv -i ./devinventory create_cluster.yml -e "_dev=1 _cluster_id=105 _cluster_id_hex=16 _cluster_name=cancer $1 _port_hadoop_ssh=5001 _port_hadoop_hue=57000 _port_hadoop_resource_manager=57001 _port_hadoop_hdfs=57002"
