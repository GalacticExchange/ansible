module DataConverter
  extend self

  def convert_keys(hash)
    hash.map {|k, v| ["_#{k}", v]}.to_h
  end

  def convert_cluster_data(s_cluster_data, env)
    #env = 'main' if env == 'aws'

    cluster_data = convert_keys(JSON.parse(s_cluster_data))
    cluster_data['_gex_env'] = env
    cluster_data['_cluster_name'] = cluster_data.delete('_name')
    cluster_data['_cluster_id'] = cluster_data.delete('_id')
    cluster_data['_cluster_uid'] = cluster_data.delete('_uid')

    cluster_data
  end

  def convert_node_data(s_node_data)
    node_data = convert_keys(JSON.parse(s_node_data))
    node_data['_node_id'] = node_data.delete('_id')
    node_data['_node_name'] = node_data.delete('_name')
    node_data['_node_uid'] = node_data.delete('_uid')
    node_data['_node_agent_token'] = node_data.delete('_agent_token')

    node_data
  end

  def convert_app_data(s_app_data)
    app_data =   convert_keys(JSON.parse(s_app_data))
    app_data['_app_id'] = app_data.delete('_id')
    app_data['_app_name'] = app_data.delete('_name')
    app_data['_app_uid'] = app_data.delete('_uid')

    app_data
  end


end