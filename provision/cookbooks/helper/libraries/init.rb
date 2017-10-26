require 'slack-notifier'

Chef.event_handler do
  on :run_failed do |exception|
    Helper::HandlerSendToSlack.send_msg_on_run_failure(exception, Chef.run_context.node)
  end
end