require "fileutils"
require_relative "../common/gexcloud_utils"

def create_proxy(service_name, source_port, destination_host, destination_port='22')
  add_vars ({
      '_service_name' => service_name,
      '_source_port' => source_port,
      '_destination_host' => destination_host,
      '_destination_port' => destination_port})

  get_processor.process_template_tree template_dir('tunnel/host')
  enable_and_start_service "proxy_#{service_name}"
end

use_container "proxy"
