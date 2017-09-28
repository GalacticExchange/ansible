class GexHelpers

  def self.run_remote_cmd(server_name, cmd)
    srv = Config.srv_host(server_name)

    SSHKit::Coordinator.new(srv).each in: :sequence do
      execute("#{cmd}")
    end

  end

  def self.run_task
    res = false

    begin
      yield

      res = true
    rescue => e
      puts "EXCEPTION: #{e.message} |**| #{e.backtrace} |**|"
      GEX_LOGGER.error_msg("EXCEPTION: #{e.message}. #{e.backtrace}")
      GEX_LOGGER.error("EXCEPTION: #{e.backtrace}")
      res = false

    end

    res
  end


end
