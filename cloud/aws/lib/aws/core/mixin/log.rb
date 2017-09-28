module AWS
  module Core
    module Mixin

      module Log

      def debug(msg)
        puts "[#{self.class}: #{msg}]"
      end

      end

    end
  end
end