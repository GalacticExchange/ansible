require "fileutils"
require_relative "../common/gexcloud_utils"


BASE_DIR_VAGRANT = "/mount/ansible/templates/cluster/vagrant"
BASE_DIR_DEDICATED = "/mount/ansible/templates/cluster/dedicated"


def node_data_dir(cluster_id, node_number)
  "/mount/ansibledata/#{cluster_id}/nodes/#{node_number}"
end


def cluster_data_dir(cluster_id)
  "/mount/ansibledata/#{cluster_id}"
end

def cluster_vars_dir(cluster_id)
  "/mount/ansibledata/#{cluster_id}/vars"
end

