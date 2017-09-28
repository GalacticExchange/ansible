require 'fog/aws'
require 'json'
require 'net/ssh'
require 'erb'

load_path = File.join(File.dirname(__FILE__),'aws/**/*.rb')

#load recursively in fixed order
Dir.glob(load_path).map {|file| [file.count("/"), file]}.sort.map {|file| file[1]}.reverse.each {|file| load file}