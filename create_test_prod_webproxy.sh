#!/bin/bash
ansible-playbook -vvvv -i ./prodinventory create_webproxy.yml -e "_cluster_id=22 _port_hadoop_ssh=5081 _port_hadoop_hue=5082 _port_hadoop_resource_manager=5083 _port_hadoop_hdfs=5084 "

