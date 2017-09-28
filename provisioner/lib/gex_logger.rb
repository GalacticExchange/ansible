require 'poseidon'
require 'logstash-logger'
require 'singleton'
require 'timeout'
require_relative 'config'

class GexLogger

  include Singleton

  KAFKA_HOSTS = ["#{Config.log_kafka_host}:#{Config.log_kafka_port}"]


  LOG_LEVELS = {
      'TRACE' => 1,
      'DEBUG' => 2,
      'INFO' => 3,
      'WARN' => 4,
      'ERROR' => 5,
      'FATAL' => 6
  }

  def initialize

    @cluster_id = nil
    @node_id = nil
    @app_id = nil

    @parent_script_path =nil
    @parent_script_content = nil

    @type_name = 'provision'


    @logger = LogStashLogger.new(
        type: :kafka,
        sync: true,
        path: Config.log_kafka_topic,
        hosts: KAFKA_HOSTS,
        formatter: ->(severity, time, progname, msg) {
          {
              type_name: @type_name,
              cluster_id: msg[:cluster_id],
              node_id: msg[:node_id],
              data: msg[:data].to_s,
              created_at: Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%LZ"),
              source_id: 3,
              level: LOG_LEVELS[severity]
          }.to_json
        }
    )

  end

  def info(msg = '')
    data = log_data(caller, msg)
    timeout_exec {
      @logger.info(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def debug(msg = '')
    data = log_data(caller, msg)
    timeout_exec {
      @logger.debug(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def warn(msg = '')
    data = log_data(caller, msg)
    timeout_exec {
      @logger.warn(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def fatal(msg = '')
    data = log_data(caller, msg)
    timeout_exec {
      @logger.fatal(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def error(msg = '')
    data = log_data(caller, msg)
    timeout_exec {
      @logger.error(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def info_start
    data = "#{trace_info(caller)[:script_name]} started"
    timeout_exec {
      @logger.info(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def info_finish
    data = "#{trace_info(caller)[:script_name]}  finished"
    timeout_exec {
      @logger.info(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def log_data(caller, msg)
    trace_data = trace_info(caller)
    "#{trace_data[:script_name]}:#{trace_data[:line]} #{trace_data[:parent_method]}   #{msg}"
  end

  def trace_info(caller)
    parent_call = caller[0].split(':')

    {
        parent_script_path: parent_call[0],
        script_name: parent_call[0].split('/').last(2).join('/'),
        line: parent_call[1],
        parent_method: parent_call[2]
    }

  end

  #This method should be called just before
  #line you wish to log
  def before_line_debug(msg = '')
    trace_data = trace_info(caller)
    if @parent_script_path != trace_data[:parent_script_path]
      @parent_script_path = trace_data[:parent_script_path]
      #p @parent_script_path
      @parent_script_content = IO.readlines(@parent_script_path)
    end


    script_line = @parent_script_content[trace_data[:line].to_i].strip

    msg = "BEFORE_LINE: `#{script_line}` #{msg}"
    data = log_data(caller, msg)
    timeout_exec {
      @logger.debug(cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: data)
    }
  end

  def set_cluster_id(cluster_id)
    @cluster_id = cluster_id
    self
  end

  def set_node_id(node_id)
    @node_id = node_id
    self
  end

  def set_app_id(app_id)
    @app_id = app_id
    self
  end


  def set_type_name(type_name)
    @type_name = type_name
    self
  end

  def timeout_exec
    begin
      Timeout.timeout(2) {
        begin
          #puts 'entered timeout block'
          yield
        rescue => e
          puts "timeout_exec crash: #{e.backtrace}"
        end
      }
    rescue => e
      puts "timeout: #{e}"
    end
  end

  def build_msg_hash(msg)
    {cluster_id: @cluster_id, node_id: @node_id, app_id: @app_id, data: msg}
  end

  def debug_msg(msg)
    puts "#{Time.now.utc}. #{msg}"
    timeout_exec {
      @logger.debug(build_msg_hash(msg))
    }
  end

  def info_msg(msg)
    timeout_exec {
      @logger.info(build_msg_hash(msg))
    }
  end

  def error_msg(msg)
    timeout_exec {
      @logger.error(build_msg_hash(msg))
    }
  end

end
