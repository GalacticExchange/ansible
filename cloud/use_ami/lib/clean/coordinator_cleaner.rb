require_relative 'clean_helper'

module Cleaner
  include CleanHelper

  def release_static_ip
    safe_execute {
      puts "coordinator eip_allocation_id : #{@config.cluster_data.fetch(:eip_allocation_id)}"
      @fog.release_address(@config.cluster_data.fetch(:eip_allocation_id))
    }
  end

end
