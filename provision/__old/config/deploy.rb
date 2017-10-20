# config valid only for current version of Capistrano
#lock '3.7.1'


set :default_shell, '/bin/bash -l'
#set :shell, '/usr/bin/bash'

set :application, 'gexcloud'
set :repo_url, 'git@git.gex:gex/empty.git'

set :rvm_type, :system


set :pty, true

set :format_options, color: false, truncate: 800
