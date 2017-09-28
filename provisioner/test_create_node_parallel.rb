
require 'parallel'

ind = 1
#system(%Q(cap dev test:provision:create_node#{ind} 2>&1))


Parallel.each(['1', '2']) do |ind|
  system(%Q(cap dev test:provision:create_node#{ind} 2>&1))
end

