class FbmessengersController < ApplicationController
  skip_before_filter :authenticate_user!

  def get_webhook
    if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == ENV['FACEBOOK_VALIDATION_TOKEN']
      puts 'Validating webhook'
      render text: params['hub.challenge']
    else
      puts 'Failed validation. Make sure the validation tokens match.'
      head :forbidden
    end
  end

  def post_webhook
    # // Make sure this is a page subscription
    return if params['object'] != 'page'

    # // Iterate over each entry, there may be multiple if batched
    params['entry'].each do |page_entry|
      # // Iterate over each messaging event
      page_entry['messaging'].each do |messaging_event|
        begin
          ChatbotService.receive(messaging_event)
        rescue Exception => ex
          Rails.logger.warn "Webhook received #{ex}"
        end
      end
    end

    # // Assume all went well.
    # //
    # // You must send back a 200, within 20 seconds, to let us know you've
    # // successfully received the callback. Otherwise, the request will time out.
    head :ok
  end
end
