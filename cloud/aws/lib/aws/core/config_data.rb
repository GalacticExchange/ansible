module AWS
  module Core
    class ConfigData

      attr_accessor :cluster_data, :nodes_data

      def initialize(cluster_id)
        @cluster_data = read_cluster_data(cluster_id)
        @nodes_data = read_nodes_data

        raise "No such credentials path: #{credentials_path}" unless path_exists?
      end

      def method_missing(name)
        name = name.to_s
        # p @cluster_data.fetch(name) #TODO

        @cluster_data.fetch(name, nil)
      end

      def read_cluster_data(cluster_id)
        if File.exist? cluster_data_path(cluster_id)
          JSON.parse(File.read(cluster_data_path(cluster_id)))
        else
          {'cluster_id' => cluster_id}
        end
      end

      def read_nodes_data
        if File.exist? nodes_data_path
          JSON.parse(File.read(nodes_data_path))
        else
          {}
        end
      end

      def cluster_data_path(cluster_id)
        "/mount/ansibledata/#{cluster_id}/credentials/cluster_data.json"
      end

      def nodes_data_path
        "/mount/ansibledata/#{cluster_id}/credentials/nodes_data.json"
      end

      def save_cluster_data
        File.write(cluster_data_path(cluster_id), JSON.pretty_generate(@cluster_data))
      end

      def save_node_data(node_data)
        File.open(nodes_data_path, "r+") do |file|
          file.flock(File::LOCK_EX)

          all_nodes = JSON.parse(file.read, symbolize_names: true)
          file.rewind
          all_nodes.merge!(node_data)
          file.write(JSON.pretty_generate(all_nodes))
          file.flush
          file.truncate(file.pos)
        end
      end

      def credentials_path
        "/mount/ansibledata/#{cluster_id}/credentials/"
      end

      def path_exists?
        Dir.exist?(credentials_path)
      end

    end
  end
end