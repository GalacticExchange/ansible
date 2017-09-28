#!/bin/sh
ansible-playbook  -vvvv  -i ./inventory   remove_proxy_port.yml \
  -e "_source_port=450"
