require 'fileutils'
require_relative '../common/gexcloud_utils'

module WebProxyUtils
  extend self


  def enable_webproxy(cluster_id, node_number, app_name, service_name)

    dest_file = "/opt/openresty/nginx/sites-available/#{cluster_id}_#{node_number}_#{app_name}_#{service_name}.conf"

    #todo changed from get_processor
    get_processor.process_template_file("/mount/ansible/templates/cluster/webproxy/templates/node/aws/server_service.conf.erb",
                                        "/mount/ansible/templates/cluster/webproxy", "gex-webproxy",
                                        destination: dest_file)


    xexecs(
        "chmod 0775 #{dest_file}",
        "ln -sf #{dest_file} /opt/openresty/nginx/sites-enabled/#{cluster_id}_#{node_number}_#{app_name}_#{service_name}.conf",
        container: $container
    )
  end

  def setup_webproxy_services(web_services, cluster_id, node_number)
    web_services.each do |s|
      add_var('_cluster_id', cluster_id)
      add_var('_node_number', node_number)
      add_var('_service_ip', s.fetch('service_ip'))
      add_var('_source_port', s.fetch('source_port'))
      add_var('_dest_port', s.fetch('dest_port'))
      add_var('_app_name', s.fetch('app_name'))
      add_var('_service_name', s.fetch('service_name'))
      enable_webproxy(cluster_id, node_number, s.fetch('app_name'), s.fetch('service_name'))
    end
    #reload_nginx TODO
  end


  def setup_webproxy_service(cluster_id, node_number, service_ip, source_port, dest_port, app_name, service_name)
    add_var('_cluster_id', cluster_id)
    add_var('_node_number', node_number)
    add_var('_service_ip', service_ip)
    add_var('_source_port', source_port)
    add_var('_dest_port', dest_port)
    add_var('_app_name', app_name)
    add_var('_service_name', service_name)
    enable_webproxy(cluster_id, node_number, app_name, service_name)
    #reload_nginx TODO
  end


  def reload_nginx
    #require_relative '../../../provisioner/lib/provision/webproxy'
    #Provision::Webproxy.restart_nginx_async
    begin
      GEX_LOGGER.debug('Trying to reload nginx..')
      dexec '/opt/openresty/nginx/sbin/nginx -s reload -c /opt/openresty/nginx/conf/nginx.conf'
    rescue
      GEX_LOGGER.warn('Failed to reload nginx')
    end
  end

end

use_container "gex-webproxy"
