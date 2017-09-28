require_relative '../../../provisioner/lib/gex_logger'

LIB_DIR = "../../../../vagrant/base/ruby_scripts"

require_relative "#{LIB_DIR}/common"

GEX_LOGGER = GexLogger.instance

def template_dir(type)
  "/mount/ansible/templates/cluster/#{_a("_server_name")}/templates/#{type}"
end

def gexcloud_process_template_trees(type)
  p = get_processor
  p.process_template_tree template_dir(type) + "/container", $container
  p.process_template_tree template_dir(type) + "/host"

  p
end

def gexcloud_remove_template_trees(type)
  process_remove_tree template_dir(type) + "/container", $container
  process_remove_tree template_dir(type) + "/host"
end


def gexcloud_remove_template_tree(type, container = nil)
  if container == nil
    remove_template_tree(template_dir(type) + "/host")
  else
    remove_template_tree(template_dir(type) + "/container", container)
  end
end
