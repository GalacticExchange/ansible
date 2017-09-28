require 'net/http'

module GexApi

  PROD_URL = 'http://api.galacticexchange.io'
  MAIN_URL = 'http://api.gex'


  def self.node_notify(event, node_uid, node_agent_token, env)
    url = env == 'prod' ? PROD_URL : MAIN_URL

    Net::HTTP.post_form(URI.join(url,'notify'), {
        'token' => node_agent_token,
        'nodeID' => node_uid,
        'event' => event
    })
  end

end