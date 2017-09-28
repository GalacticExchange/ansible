#!/usr/bin/env ruby

require_relative "webproxy_utils"

safe_exec {

  cluster_id = ENV.fetch('_cluster_id')
  GEX_LOGGER.set_cluster_id(cluster_id).info_start


  parse_and_init('webproxy', cluster_id)


  FRAMEWORKS.each do |f|
    add_var "_#{f}_ipv4", get_framework_master_ip(cluster_id, f)
    GEX_LOGGER.debug("added var _#{f}_ipv4=#{get_value("_#{f}_ipv4")}")
  end

  #TODO
  services = [
      {
          'name' => 'hadoop_hue',
          'ip' => get_value('_hue_ipv4'),
          'src_port' => get_value('_port_hue'),
          'dest_port' => '8000'
      },
      {
          'name' => 'hadoop_resource_manager',
          'ip' => get_value('_hadoop_ipv4'),
          'src_port' => get_value('_port_hadoop_resource_manager'),
          'dest_port' => '8088'
      },
      {
          'name' => 'hadoop_hdfs',
          'ip' => get_value('_hadoop_ipv4'),
          'src_port' => get_value('_port_hdfs_namenode_webui'),
          'dest_port' => '50070'
      },
      {
          'name' => 'spark_history',
          'ip' => get_value('_hadoop_ipv4'),
          'src_port' => get_value('_port_spark_history'),
          'dest_port' => '18080'
      },
      {
          'name' => 'spark_master_webui',
          'ip' => get_value('_hadoop_ipv4'),
          'src_port' => get_value('_port_spark_master_webui'),
          'dest_port' => '18081'
      }
  ]

  [{name: 'elastic', port: '9200'}, {name: 'kudu', port: '8051'}, {name: 'impala', port: '25000'}].each {|s|
    if get_value('_components').include?(s[:name])
      services.push(
          {
              'name' => s[:name],
              'ip' => get_value('_hadoop_ipv4'),
              'src_port' => get_value("_port_#{s[:name]}"),
              'dest_port' => s[:port]
          }
      )
    end
  }


  add_var('services', services)

  get_processor.process_template_tree template_dir("cluster"), $container
  GEX_LOGGER.debug('Processed templates')


  xexecs "ln -sf /opt/openresty/nginx/sites-available/#{cluster_id}.conf /opt/openresty/nginx/sites-enabled/#{cluster_id}.conf", container: $container

  begin
    #GEX_LOGGER.debug('Trying to reload nginx..')
    #xexecs "/opt/openresty/nginx/sbin/nginx -s reload -c /opt/openresty/nginx/conf/nginx.conf", container: $container
  rescue
    #GEX_LOGGER.warn('Failed to reload nginx')
    #xexecs "/opt/openresty/nginx/sbin/nginx -s reload -c /opt/openresty/nginx/conf/nginx.conf", container: $container
  end

  WebProxyUtils.reload_nginx #TODO

  GEX_LOGGER.info_finish
}
