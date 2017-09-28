require_relative 'spec_helper'
require 'zookeeper'

describe PreConfig do

  before :all do

    setup_dirs

    Fog.mock!

    @pre_conf = PreConfig.new ({
        aws_access_key_id: 'access_key_id',
        aws_secret_access_key: 'secret_key',
        cluster_id: CLUSTER_ID,
        cluster_uid: '221133',
        region: 'us-west-2',
        cluster_name: 'cluster_name',
        env: GEX_ENV
    })
  end

  describe 'creds path ' do
    it 'exists' do
      expect(Dir).to exist(@pre_conf.config.credentials_path)
    end
  end

  describe '#create_key_pair' do
    it 'creates new key' do
      @pre_conf.create_key_pair
      expect(File).to exist(@pre_conf.config.key_path)
    end
  end

  describe '#create_vpc' do
    it 'creates vpc' do
      @pre_conf.create_vpc
      expect(@pre_conf.config.cluster_data[:vpc_id]).to start_with('vpc-')
    end

    it 'has propper tags' do
      vpc = @pre_conf.fog.describe_vpcs('vpcId' => @pre_conf.config.cluster_data[:vpc_id]).body
      vpc = vpc['vpcSet'][0]
      expect(vpc['tagSet']['cluster_uid']).to eq(@pre_conf.config.cluster_data[:cluster_uid])
      expect(vpc['tagSet']['Name']).to eq("gex-#{@pre_conf.config.cluster_data[:cluster_uid]}")
    end
  end

  describe "#create_subnet" do
    it 'creates subnet' do
      @pre_conf.create_subnet
      expect(@pre_conf.config.cluster_data[:subnet_id]).to start_with('subnet-')
    end
  end

  describe '#create_security_group' do
    it 'creates security group' do
      @pre_conf.create_security_group
      expect(@pre_conf.config.cluster_data[:security_group_id]).to start_with('sg-')
    end
  end


  describe '#setup_gateway' do
    it 'creates gateway' do
      @pre_conf.setup_gateway
      expect(@pre_conf.config.cluster_data[:gateway_id]).to start_with('igw-')
    end

    it 'saves route table id' do
      expect(@pre_conf.config.cluster_data[:route_table_id]).to start_with('rtb-')
    end

  end

  describe '#save_cluster_data' do
    it 'saves json file on disk' do
      @pre_conf.save_cluster_data
      expect(File).to exist(@pre_conf.config.cluster_json_file_path)
    end

    it 'has the same data' do
      data = JSON.parse(File.read(@pre_conf.config.cluster_json_file_path), symbolize_names: true)
      expect(@pre_conf.config.cluster_data).to eq(data)
    end

  end

  #TODO
  #describe '#create_zk_connection' do
  #  it 'connects normally' do
  #    @pre_conf.create_zk_connection
  #    expect(@zk).not_to eq(nil)
  #  end
  #end

  #TODO
  describe '#create_nodes_file' do
    it 'creates json file in zookeeper with empty arr' do
      @pre_conf.create_nodes_file
      data = JSON.parse(File.read(@pre_conf.config.nodes_json_file_path))
      #data = Zookeeper.new("#{ZOOKEEPER_HOST}:#{ZOOKEEPER_PORT}")
      expect(data).to eq([])
    end
  end

  describe '#check_existanse' do
    it 'returns true' do
      expect(@pre_conf.check_existence).to be(true)
    end
  end

  describe '#instantiate' do

    it 'creates pre_conf object' do
      @pre_conf = PreConfig.instantiate(CLUSTER_ID)
      expect(@pre_conf).not_to eq(nil)
    end

  end

end