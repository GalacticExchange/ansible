module AWS
  module Core
    module Mixin

      module Constants

        USER_DATA_DIR = File.join(File.dirname(__FILE__),'../../../../templates/user_data/')

        BASIC_USER_DATA = ERB.new(File.read(File.join(USER_DATA_DIR, 'basic.erb')) ).result(binding)

        CIDR_WEAVE = '10.175.0.0/16'

        CIDR_VPC = '10.176.0.0/16'

        MAX_RETRIES_AMOUNT = 60

        SWAP_SIZE = 4096

        GEXD_PORT = '48746'

        GEX_AWS_ID = '233320865899'

        GEX_SERVERS = {
            'main' => {
                'api' => '46.172.71.53'
            },
            'prod' => {
                'api' => '104.247.194.115'
            }
        }

      end

    end
  end
end