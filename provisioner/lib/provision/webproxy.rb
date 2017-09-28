module Provision
  class Webproxy

    ## real job
    def self.reload_nginx

      GEX_LOGGER.debug_msg("STARTING webproxy nginx restart")
      puts 'STARTING webproxy nginx restart'

      s = Time.now.utc.to_s
      #res_cmd = Provisioner::DockerUtils.dexec("webproxy", 'touch /tmp/restart.txt')

      DockerUtils.dexec("webproxy", %Q(echo '#{s}' >> /tmp/log_restart.log))
      p DockerUtils.dexec("webproxy", %Q(/opt/openresty/nginx/sbin/nginx -s reload -c /opt/openresty/nginx/conf/nginx.conf))


      #sleep 30

      GEX_LOGGER.debug_msg("FINISHED webproxy nginx restart")
      puts 'FINISHED webproxy nginx restart'

    end

    def self.reload_nginx_async
      t = Time.now.utc
      tnow = t.to_i

      # set issued time to redis
      RedisUtils.set(redis_key_time_last_issued, tnow, 24*60*60)

      #plain sidekiq call
      #ProvisionReloadWebproxyNginxWorker.perform_async(tnow)

      #gush call
      ReloadNginxWorkflow.create(tnow).start!


    end

    def self.redis_key_time_last_issued
      "jobs_data:provision_restart_webproxy:time_issued_last"
    end
  end
end
