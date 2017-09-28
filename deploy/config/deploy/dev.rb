set :stage, :dev

set :gex_env, 'main'

set :gex_config, {
  dir_data: "/mnt/data/gexcloud-dev-data/",
}


# servers
server  "10.1.0.12", user: 'mmx', password: 'PH_GEX_PASSWD1', roles: %w{mainhost}, no_release: true
set :host_user, 'mmx'

set :ssh_options, { forward_agent: false, paranoid: false, password: 'PH_GEX_PASSWD1'}



