
set :gex_env, 'main'

set :gex_config, {
    dir_clusters_data: "/mount/ansibledata/",
    dir_scripts: "/mount/ansible/",
}

#set :pty, true

# servers
gex_servers =  JSON.parse(File.read('/etc/secrets/secrets.json'))

server '51.0.1.55', user: 'root', password: gex_servers['prov_pswd'], roles: %w{provisioner}, no_release: true
server '51.0.1.8', user: 'root', password: gex_servers['openvpn_pswd'], roles: %w{openvpn}, no_release: true

# server '51.1.0.50', user: 'root', password: gex_servers['master_pswd'], roles: %w{master}, no_release: true
# server '51.1.0.50', user: 'root', password: gex_servers['proxy_pswd'], roles: %w{proxy}, no_release: true
# server '51.1.0.50', user: 'root', password: gex_servers['webproxy_pswd'], roles: %w{webproxy}, no_release: true

#role :app, "server1", "server2", "server3"


set :ssh_options, {forward_agent: true, paranoid: false}


#set :kafka, Kafka.new(seed_brokers: ['51.0.0.62:9092'])


#set :default_shell, '/bin/bash -l'