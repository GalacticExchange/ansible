#!/bin/bash
#ansible-playbook -vvvv -i ./inventory create_webproxy.yml -e "_dev=1 _cluster_id=105 _port_hue=7000 _port_resource_manager=7001 _port_hdfs=7002 _webproxydomainname=devwebproxy.gex"
ansible-playbook -vvvv -i ./inventory create_webproxy.yml -e "_dev=1 _cluster_id=107 _port_hadoop_hue=5082 _port_hadoop_resource_manager=5083 _port_hadoop_hdfs=5084 "
