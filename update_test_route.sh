#!/bin/bash

ansible-playbook  -vvvv  -i ./inventory   update_container_route.yml \
  -e "_cluster_id=110 _node_number=1 _ip_address=23.45.65.56"
