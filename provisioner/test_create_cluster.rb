require_relative 'lib/init'
require_relative 'lib/init/sidekiq'

cluster_id = 99

cluster_data = %Q(
{
  "id": 99,
  "uid": "123456",
  "cluster_type": "onprem",
  "name": "gex-cluster",
  "id_hex": "63",
  "hadoop_type": "cdh",
  "hadoop_app_id": 1183,
  "port_ssh": 1511,
  "port_hadoop_resource_manager": 1512,
  "port_hdfs": 1513,
  "port_hdfs_namenode_webui": 1514,
  "port_hue": 1515,
  "port_spark_master_webui": 1516,
  "port_spark_history": 1517,
  "port_elastic": 1518,
  "components": [
    "hdfs",
    "kudu",
    "impala",
    "hive",
    "kafka",
    "elasticsearch",
    "neo4j",
    "nifi",
    "yarn",
    "cassandra",
    "spark"
  ]
})

ClusterCreateWorker.perform_async(cluster_id, cluster_data)