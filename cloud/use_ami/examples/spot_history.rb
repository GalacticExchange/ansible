#!/usr/bin/env ruby
require 'fog/aws'
#require 'net/http'


fog = Fog::Compute.new(
    :provider => 'AWS',
    :region => 'us-west-2',
    :aws_access_key_id => 'PH_GEX_KEY_ID',
    :aws_secret_access_key => 'PH_GEX_ACESS_KEY'
)

now = Time.now
#puts now.iso8601

hour_ago = now - 3600


result = fog.describe_spot_price_history({
                                             'AvailabilityZone' => 'us-west-2a',
                                             'InstanceType' => ['m4.large'],
                                             'ProductDescription' => 'Linux/UNIX',
                                             'StartTime' => hour_ago.iso8601
                                         })

puts result.body['spotPriceHistorySet']
puts

amount = result.body['spotPriceHistorySet'].length

current = result.body['spotPriceHistorySet'][0]['spotPrice']

sum = 0

max = 0
min = 999

result.body['spotPriceHistorySet'].each do |item|
  sum += item['spotPrice']

  if  item['spotPrice'] > max
    max = item['spotPrice']
  end

  if item['spotPrice'] < min
    min = item['spotPrice']
  end

end

average = sum/amount

puts "amount: #{amount}"
puts

puts "min: #{min} $"
puts "max: #{max} $"
puts "average: #{average.round(4)} $"
puts "current: #{current} $"

puts

if average < current
  puts 'current spot price is too big'
  #exit
end

bid = (average - current)*0.5+current
puts "possible bid: #{bid.round(4)}"


#TODO launch machine
spot_result = fog.request_spot_instances('ami-4d00c82d','m4.large',average,{'LaunchSpecification.KeyName' => 'GEXExp'})
puts spot_result.body

puts spot_result.body['requestId'] # or 'spotInstanceRequestId' ???

#!!!! ['spotInstanceRequestSet'][0]['instanceId'] - instance id if one has been launched to fulfill request

#TODO check request untill instance is up then ssh and run gex install
#