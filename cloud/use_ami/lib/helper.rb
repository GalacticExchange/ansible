
module Helper

  KEY_NAME = 'ClusterGX_key'

  CIDR_WEAVE = '10.175.0.0/16'

  VPN_AWS_IP = '35.167.41.33' #USING public ip to make it work in other regions
  VPN_WEAVE_IP = '10.175.128.0'
  VPN_AWS_ID = 'i-0c9ef5ac6f851cac4'

  TEST_PATH = File.expand_path('../test/', __FILE__)
  OPENVPN_SERVER_IP_FILE = File.join(TEST_PATH, 'OPENVPN_SERVER_IP')

  CLUSTER_JSON_FILE = 'cluster_data.json'
  NODES_JSON_FILE = 'nodes_data.json'

  GEXD_DEB = {
      :main => {
          :repo => 'khotkevych',
          :package => 'gexservertest'
      },
      :prod => {
          :repo => 'gex',
          :package => 'gexserver'
      }
  }

  #TODO or not todo..
  GEXD_PORT = '48746'


  MAX_RETRIES_AMOUNT = 60 #10 minutes

  COORDINATOR_BASE_NAME = 'gex-coordinator-'
  NODE_BASE_NAME = 'gex-node-'

  API_STATE = 'http://'

  class Config
    attr_reader :credentials_path, :cluster_json_file_path, :nodes_json_file_path

    attr_accessor :cluster_data, :key_path

    def initialize(params = {})
      @credentials_path = File.join(
          ENV.fetch('gex.dir_clusters_data', '/mount/ansibledata/'),
          "#{params.fetch(:cluster_id)}/credentials"
      )
      @cluster_json_file_path = File.join(@credentials_path, CLUSTER_JSON_FILE)
      @nodes_json_file_path = File.join(@credentials_path, NODES_JSON_FILE)

      @cluster_data = get_cluster_data
      @key_path = File.join(@credentials_path, "#{@cluster_data.fetch(:key_name, 'None')}.pem")

    end

    def get_cluster_data
      if File.exist?(@cluster_json_file_path)
        return JSON.parse(File.read(@cluster_json_file_path), symbolize_names: true)
      end
      {}
    end

    def get_nodes_data
      if File.exist?(@nodes_json_file_path)
        return JSON.parse(File.read(@nodes_json_file_path), symbolize_names: true)
      end
      []
    end

  end


end