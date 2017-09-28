require 'net/ssh'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ribble.rb [options]"

  opts.on('-i', '--inventory=inventory', 'path to inventory') do |v|
    options[:inventory] = v
  end
end.parse!

raise 'No inventory specified' if options[:inventory].nil? && !File.exist?('inventory.rb')

options[:inventory] = 'inventory.rb' if options[:inventory].nil?

require_relative "#{options[:inventory]}"

def hosts(hostname)
  $hostname = hostname.to_sym
  yield
end

def command(cmd)
  p "hostname: #{$hostname}"
  p cmd
end

require_relative ARGV[0]

