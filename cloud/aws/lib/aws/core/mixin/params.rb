module AWS
  module Core
    module Mixin

      module Params

        def method_missing(name, *args, &block)
          name = name.to_s
          @init_params[name] = args[0]
        end

        def append_user_data(user_data)
          debug('Appending USER_DATA')
          @user_data << '
          '
          @user_data << user_data
        end



      end


    end
  end
end