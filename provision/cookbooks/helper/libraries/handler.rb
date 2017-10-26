module Helper
  module HandlerSendToSlack

    EXCEPTION_URL = 'https://hooks.slack.com/services/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'.freeze

    def self.send_msg_on_run_failure(exception, node)

      channel_name = node.chef_environment == 'main' ? '#main_errors' : '#prod_errors'

      message = "#{exception.backtrace.inspect}\n"

      ex_attachment = {
          fallback: 'Exception_message',
          text: "#{message}",
          color: '#ffff00'
      }

      notifier = Slack::Notifier.new(EXCEPTION_URL, channel: channel_name, username: 'chef-solo')
      notifier.post(text: "Exception | #{Time.now.rfc2822}", attachments: [ex_attachment])
    end

  end

end

