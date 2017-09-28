class ProvisionTask

  ### props

  def gex_env
    @gex_env
  end

  def cluster_id
    @cluster_id
  end

  def node_id
    @node_id
  end


  def cluster_data
    @cluster_data ||= {}

    @cluster_data
  end

  def node_data
    @node_data ||= {}

    @node_data
  end



  ### init
  def init
    #
    @gex_env = ENV.fetch('gex_env', 'main')
    @cluster_id = ENV.fetch('_cluster_id', nil)
    @node_id = ENV.fetch('_node_id', nil)

    puts "init"
    puts "init. cluster: #{@cluster_id}, #{@node_id}"


    #node_data = DataConverter.convert_node_data(ENV.fetch('_node_data'))

    #node_id = node_data.fetch('_node_id')
    #cluster_id = node_data.fetch('_cluster_id')

    # update data on consul from input
    _cluster_data = ENV.fetch('_cluster_data', '')
    unless _cluster_data.empty?
      ConsulUtils.update_cluster_data(cluster_id, _cluster_data)
    end

    # update node_data in consul
    _node_data = ENV.fetch('_node_data', '')
    unless _node_data.empty?
      _node_data = DataConverter.convert_node_data(_node_data)
      ConsulUtils.update_node_data(cluster_id, node_id, _node_data)
    end


  end


  def init_node
    # get cluster data from consul
    ConsulUtils.connect(cluster_id)

    @cluster_data = ConsulUtils.get_cluster_data
    @node_data = ConsulUtils.get_node_data(node_id)
  end

end
