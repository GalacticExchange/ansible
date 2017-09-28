#!/bin/bash

#!/bin/bash
if [ -z "$1" ]
  then
    echo "No port number supplied"
    exit
fi



ansible-playbook  -i ./inventory   check_proxy_status.yml -e "_source_port=$1"