module Provision
  class Notification

    def self.notify_api_sidekiq(event, data)

      res = Sidekiq::Client.push(
        'queue' => 'provisionnotify', 'retry' => false,
        'class' => 'ProvisionNotificationsWorker',
        'args' => [{event: event, data: data}]
      )

      if res
        #TODO(bogdan): log notify sent
        puts "#{event} notification sent. job_id: #{res}"
      else
        # TODO(bogdan): log notify fail
        puts "#{event} notification for #{data} failed."
      end

    end

  end
end
