set :stage, :prod
set :gex_env, 'prod'

set :gex_config, {
    dir_data: "/disk2/gexcloud-data/",
}

#set :git_tag, 'prod_20170310_2'
#set :git_tag, 'prod_20170613_v2'
#set :git_tag, 'prod_2017_08_07_v3'
set :git_tag, 'prod_2017_08_08_v2'

#set :branch do
#  'prod_20170310_2'
#end



# servers
server  "gex3.galacticexchange.io", user: 'gex', password: 'PH_GEX_PASSWD3gx', roles: %w{mainhost}
#server  "51.0.0.55", user: 'root', password: 'PH_GEX_PASSWD1', roles: %w{provisioner}#, port: 9022

#set :host_user, 'root'
#set :use_sudo, false

##
set :ssh_options, { forward_agent: true, paranoid: false}



