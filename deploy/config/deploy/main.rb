set :stage, :main

set :gex_env, 'main'

set :gex_config, {
    dir_data: "/disk2/gexcloud-main-data/",
}


# servers
server  "51.1.0.50", user: 'gex', password: 'PH_GEX_PASSWD2', roles: %w{mainhost}
#server  "51.0.0.55", user: 'root', password: 'PH_GEX_PASSWD1', roles: %w{provisioner}#, port: 9022

#set :host_user, 'root'
#set :use_sudo, false

##
set :ssh_options, { forward_agent: true, paranoid: false}



