#!/bin/sh
ansible-playbook  -vvvv  -i ./inventory   create_proxy_port.yml \
  -e "_dev=1  _cluster_id=105 _port_ssh=502"
