### AWS setup

####Cluster creation steps:

1. Basic configure
    - Creates key pair (saves ClusterGX`N`.pem on disk)
    - Creates VPC
    - Creates gateway
    - Creates subnet
    - Creates security group
    - Creates peering connection with main vpc
    - Creates `nodes_data.json` file in zookeeper
    - Creates `cluster_data.json` file on disk
    - Saves data in `cluster_data.json`
    
    Script: **run_basic_configure.rb**  
    Params from env: 
        
        aws_access_key_id: ENV['_aws_access_key_id'],
        aws_secret_access_key: ENV['_aws_secret_key'],
        cluster_id: ENV['_cluster_id'],
        cluster_uid: ENV['_cluster_uid'],
        region: ENV['_aws_region'],
        env: ENV.fetch('_gex_env', 'prod')


2. Cluster coordinator
    - Starts new coordinator instance
    - Launches weave in server mode
    - Attaches elastic (static) ip
    - Saves coordinator data in `cluster_data.json`
    
    Script: **run_coordinator.rb**  
    Params from env:
    
        cluster_id: ENV['_cluster_id']
---

#### Nodes creation steps

1. Node
    - Starts new node instance
    - Launches weave in node mode
    - Installs(updates) gex client
    - Passes agent_token and node_uid to gex client
    
    Script: **run_node.rb**  
    Params from env:
    
        hadoop_type: ENV.fetch('_hadoop_type'),
        cluster_id: ENV.fetch('_cluster_id'),
        instance_type: ENV.fetch('_instance_type'),
        gex_node_uid: ENV.fetch('_node_uid'),
        node_agent_token: ENV.fetch('_node_agent_token'),
        volume_size: ENV.fetch('_volume_size')