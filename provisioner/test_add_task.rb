require_relative 'lib/init'
require_relative 'lib/init/sidekiq'


### add task
node_id=100
Sidekiq::Client.push('queue' => 'provisionnotify', 'retry' => 10,
                     'class' => 'ProvisionNotifyWorker',
                     #'args' => ["node_aws_state_changed", {node_id: node_id}]
                     'args' => ["node_aws_state_changed"]
)

puts "OK: added"
#cls = 'ProvisionRestartWebproxyWorker'
#args = []

#ProvisionRestartWebproxyWorker.perform_async

=begin
Sidekiq::Client.push(
    'class' => cls, 'args' => args,
    #'queue' => 'provision', 'retry' => 20, 'unique'=> :until_executing
    'queue' => 'provision', 'retry' => 20, 'unique'=> :while_executing

)
=end
