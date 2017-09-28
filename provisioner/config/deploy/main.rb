
set :gex_env, 'main'

set :gex_config, {
    dir_clusters_data: "/mount/ansibledata/",
    dir_scripts: "/mount/ansible/",
}

#set :pty, true

# servers

server '51.0.0.55', user: 'root', password: 'PH_GEX_PASSWD1', roles: %w{provisioner}, no_release: true
server '51.1.0.50', user: 'root', password: 'PH_GEX_PASSWD2', roles: %w{master}, no_release: true
server '51.1.0.50', user: 'root', password: 'PH_GEX_PASSWD2', roles: %w{openvpn}, no_release: true
server '51.1.0.50', user: 'root', password: 'PH_GEX_PASSWD2', roles: %w{proxy}, no_release: true
server '51.1.0.50', user: 'root', password: 'PH_GEX_PASSWD2', roles: %w{webproxy}, no_release: true

#server '77.0.0.99', user: 'root', password: 'root', roles: %w{webproxy}, no_release: true
#server 'proxy', user: 'root', password: 'root', roles: %w{proxy}, no_release: true

#role :app, "server1", "server2", "server3"


set :ssh_options, {forward_agent: true, paranoid: false}


#set :kafka, Kafka.new(seed_brokers: ['51.0.0.62:9092'])


#set :default_shell, '/bin/bash -l'