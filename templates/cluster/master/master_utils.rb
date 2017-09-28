#!/usr/bin/env ruby

require 'fileutils'
require_relative '../common/gexcloud_utils'

def gex_cloud_create_and_configure_master_container(framework, cluster_id)

  use_container("#{framework}-master-#{cluster_id}")

  tag = "gex/#{framework}_#{_a("_hadoop_type")}"

  host_records = []

  FRAMEWORKS.each do |f|
    unless f == framework
      host_records.push({:ip => get_framework_master_ip(cluster_id, f),
                         :domain_name => "#{f}-master-#{cluster_id}.gex",
                         :aliases => "#{f}-master-#{cluster_id}"})
    end
  end


  assert _a("_dns_ip") == "51.0.1.8"

  GEX_LOGGER.debug('before create container')
  dcreate_container(tag, BOOTSTRAP, VOLUMES, get_framework_master_ip(cluster_id, framework),
                    $container, _a("_dns_ip"), host_records: host_records)

  GEX_LOGGER.debug('before docker overlay connect')
  texec "docker network connect overlay --ip #{get_framework_master_ip(cluster_id, framework)} #{$container}"

  add_vars({"_container" => $container,
            "_container_ip" => _a("_#{framework}_ipv4")}
  )

  processor = get_processor

  # TODO
  add_vars('_components' => ['kafka', 'zookeeper'])
  GEX_LOGGER.debug('before template processing')
  processor.process_template_tree template_dir("master")

  create_init_lock

  enable_and_start_container_service

  wait_until_running

  GEX_LOGGER.debug('before template processing')
  gexcloud_pull_and_process_git_template_trees("#{framework}/master", processor, $container)

  remove_init_lock

  assert_drunning

end


def remove_container_from_domain_resolution

  FileUtils.rm_f(hosts_dir)

  remove_contaner_from_avahi
end


def init_master_vars(cluster_id)
  GEX_LOGGER.debug('initializing master vars')

  add_var "_hadoop_conf_dir", "/etc/hadoop/conf"
  add_var "_hadoop_bin_dir", "/usr/bin"
  add_var "_hadoop_ipv4", get_framework_master_ip(cluster_id, "hadoop")
  add_var "_hue_ipv4", get_framework_master_ip(cluster_id, "hue")
end


def update_framework_master_with_slave(framework, vars, slave_ip)

  unless framework == "hadoop"
    return
  end


  node_name = vars["_node_name"]

  hadoop_conf_dir = vars["_hadoop_conf_dir"]
  hadoop_bin_dir = vars["_hadoop_bin_dir"]

  assert_nnil node_name, hadoop_bin_dir, hadoop_conf_dir


  tmp_file = pull_from_container "#{hadoop_conf_dir}/slaves"

  append_file_with_lines tmp_file, "hadoop-#{node_name}.gex"

  push_to_container "#{hadoop_conf_dir}/slaves"


  #dexec_background "#{hadoop_bin_dir}/hadoop dfsadmin -refreshNodes"
  #dexec_background "#{hadoop_bin_dir}/yarn rmadmin -refreshNodes"

  dexec("#{hadoop_bin_dir}/hadoop dfsadmin -refreshNodes") if get_value('_components').include?('hdfs')

  dexec("#{hadoop_bin_dir}/yarn rmadmin -refreshNodes") if get_value('_components').include?('yarn')


end

def remove_slave_from_master(node_name, hadoop_conf_dir, hadoop_bin_dir)

  tmp_file = pull_from_container "#{hadoop_conf_dir}/slaves"

  delete_string_matches tmp_file, "hadoop-#{node_name}"

  push_to_container "#{hadoop_conf_dir}/slaves"

  dexec("#{hadoop_bin_dir}/hadoop dfsadmin -refreshNodes") if get_value('_components').include?('hdfs')

  dexec("#{hadoop_bin_dir}/yarn rmadmin -refreshNodes") if get_value('_components').include?('yarn')
end


def remove_master_container(framework, cluster_id)

  use_container "#{framework}-master-#{cluster_id}"

  disable_and_remove_container_service

  drm

end




