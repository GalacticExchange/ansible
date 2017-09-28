module AWS
  module Core
    module Mixin

      module Helper

        def safe_execute(exception_class=nil)
          begin
            yield
          rescue exception_class || StandardError => e
            warn "EXCEPTION HANDLED #{e.class} - #{e}"
          end
        end

      end

    end
  end
end