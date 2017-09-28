#require_relative 'lib/init'
#require_relative 'lib/init/sidekiq'
#require_relative 'lib/init/gush'

#Provision::Notification.notify_api_sidekiq('cluster_provision_created', {cluster_id: 564})

require 'sidekiq'

###
Sidekiq.configure_server do |config|
  config.redis = {
      url: "redis://51.0.0.12:6379/0",
      namespace: "gex_main_sidekiq",
  }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://51.0.0.12:6379/0",
                   namespace: "gex_main_sidekiq" }
end



res = Sidekiq::Client.push(
    'queue' => 'provisionnotify', 'retry' => false,
    'class' => 'ProvisionNotificationsWorker',
    'args' => [{event: 'cluster_provision_uninstalled', data: {cluster_id: 756}}]
)