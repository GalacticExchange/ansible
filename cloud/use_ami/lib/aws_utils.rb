module AwsUtils

  def get_state(instance_id)
    resp = @fog.describe_instances('instance-id' => instance_id)
    resp.body['reservationSet'][0]['instancesSet'][0]['instanceState']['name']
  end


  def wait_for_state(state, instance_id)
    count = 0
    while get_state(instance_id) != state
      count = count + 1
      sleep(15)
      raise ('Cannot change state') if count > Helper::MAX_RETRIES_AMOUNT
    end

  end

end