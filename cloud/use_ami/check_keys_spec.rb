require 'rspec'
require 'aws-sdk'

#noinspection RubyArgCount
aws = Aws::EC2::Client.new(
    access_key_id: ENV['_aws_access_key_id'],
    secret_access_key: ENV['_aws_secret_key'],
    region: ENV['_region']
)

describe 'Check key pair' do

  it 'raises particular exception' do
    expect{
      aws.create_vpc({
                         dry_run: true,
                         cidr_block: '10.177.0.0/16', # required
                         instance_tenancy: "default", # accepts default, dedicated, host
                         amazon_provided_ipv_6_cidr_block: false
                     })
    }.to raise_error('Request would have succeeded, but DryRun flag is set.')


  end

end
