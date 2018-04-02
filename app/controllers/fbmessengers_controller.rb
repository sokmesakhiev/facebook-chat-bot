class FbmessengersController < ApplicationController
  skip_before_filter :authenticate_user!

  def oauthcallback; end

  def get_webhook
    if params['hub.mode'] == 'subscribe' && params['hub.verify_token'] == ENV['FACEBOOK_VALIDATION_TOKEN']
      puts 'Validating webhook'
      render text: params['hub.challenge']
      # res.status(200).send(params['hub.challenge'])
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
        if messaging_event['optin']
          Message.receivedAuthentication(messaging_event)
        elsif messaging_event['message']
          Message.received_message(messaging_event)
        elsif messaging_event['delivery']
          Message.receivedDeliveryConfirmation(messaging_event)
        elsif messaging_event['postback']
          Message.received_postback(messaging_event)
        elsif messaging_event['read']
          Message.receivedMessageRead(messaging_event)
        elsif messaging_event['account_linking']
          Message.receivedAccountLink(messaging_event)
        else
          puts "Webhook received unknown messaging_event: #{messaging_event}"
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
