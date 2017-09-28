class ProvisionCreateNodeWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'provision', retry: 20


  def perform(cluster_id, node_id)
    require_relative '../lib/provision_node'

    t = Time.now.utc

    puts("start create node. args: #{cluster_id}, #{node_id}. #{t}")

    #
    File.open('/tmp/sidekiq1.txt', 'a+') { |file| file.puts("start #{cluster_id}, #{node_id}. #{t}") }

    # work
    #sleep 120+Random.rand(60)
    ProvisionNode.create_node


    ## finish
    t = Time.now.utc
    File.open('/tmp/sidekiq1.txt', 'a+') { |file| file.puts("done #{s}. #{t}") }
  end



end

