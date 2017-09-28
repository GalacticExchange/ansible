class NginxReloadJob < Gush::Job

  def work

    time_issued = params[:time_issued]

    require_relative '../lib/provision/webproxy'

    #
    tnow = Time.now.utc
    t = tnow.to_i

    #
    last_issued = RedisUtils.get(Provision::Webproxy.redis_key_time_last_issued, 0)
    last_issued = last_issued.to_i

    #GEX_LOGGER.debug_msg "last issued = #{Time.at(last_issued)}, todo time- #{Time.at(time_issued)}"

    if time_issued>0 && last_issued > 0 && time_issued < last_issued
      # skip
      GEX_LOGGER.debug_msg "SKIPPED. time: #{Time.at(time_issued)}"

      return true
    end


    # work
    # set time to redis
    #RedisUtils.set("jobs_data:provision_restart_webproxy:time_issued_last", time_issued, 24*60*60)

    # work
    res = Provision::Webproxy.reload_nginx


    ## finish
    GEX_LOGGER.debug_msg("finished job: webproxy restart. issued: #{Time.at(time_issued)}")

  end

end