cookbook_path File.absolute_path(File.join(File.dirname(__FILE__), 'cookbooks'))
environment_path File.absolute_path(File.join(File.dirname(__FILE__), 'environments'))
file_cache_path '/tmp/chef_solo_cache'
