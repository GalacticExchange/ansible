# Sidekiq


* run

_gex_env=development bundle exec sidekiq -r ./sidekiq_provision.rb -c 1 -q provision

-C ./config/sidekiq/sidekiq_provision.yml


# Sidekiq for API

* run from API project
RAILS_ENV=development bundle exec sidekiq -e development -c 1 -t 18000 -C /projects/apihub/config/sidekiq.all_nolog.yml 
      
      




# god to monitor sidekiq

god -c /opt/god/master.conf



# debug

__gex_env=main _cluster=465 _node_id=940 ruby test_create_node.rb


# Gush

cd provisioner

_gex_env=development bundle exec gush workers



* gush status
_gex_env=development bundle exec gush list




## god monitoring for gush


## debug

* run sidekiq manually

_gex_env=development bundle exec sidekiq -r /mnt/data/projects/mmx/ansible/provisioner/Gushfile.rb -c 1 -q provisiongush -e development -v

