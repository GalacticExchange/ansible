
require_relative 'clean_helper'

module Cleaner
  include CleanHelper


  def terminate
    super

    File.open(@config.nodes_json_file_path, "r+") do |file|
      file.flock(File::LOCK_EX)

      all_nodes = JSON.parse(file.read, symbolize_names: true)
      file.rewind
      all_nodes = all_nodes.delete_if { |node| node[:gex_node_uid] == @node_data[:gex_node_uid] }
      file.write(JSON.pretty_generate(all_nodes))
      file.flush
      file.truncate(file.pos)
    end

  end
end