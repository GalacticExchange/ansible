#!/usr/bin/env bash

echo 'PH_GEX_PASSWD1' | sudo -S ruby /work/ansible/cloud/use_ami/openvpn_test/run_server.rb
if [[ $? != 0 ]]; then
    exit 1
fi
echo 'PH_GEX_PASSWD1' | sudo -S ruby /work/ansible/cloud/use_ami/openvpn_test/run_client.rb