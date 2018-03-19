class FbmessengersController < ApplicationController

  def oauthcallback
  end

  def get_webhook
  	if (params['hub.mode'] === 'subscribe' && params['hub.verify_token'] === FACEBOOK::CONFIG["validationToken"])
	    puts "Validating webhook"
      render :text => params['hub.challenge']
	    # res.status(200).send(params['hub.challenge'])
	  else
	    puts "Failed validation. Make sure the validation tokens match."
	    head :forbidden
	  end
  end

  def post_webhook
  	data = params;

    # // Make sure this is a page subscription
    if (data["object"] == 'page')
      # // Iterate over each entry
      # // There may be multiple if batched
      data["entry"].each do |pageEntry|
        pageID = pageEntry["id"];
        timeOfEvent = pageEntry["time"];

        # // Iterate over each messaging event
        pageEntry["messaging"].each do |messagingEvent|
          if (messagingEvent["optin"])
            Message.receivedAuthentication(messagingEvent);
          elsif (messagingEvent["message"])
            Message.receivedMessage(messagingEvent);
          elsif (messagingEvent["delivery"])
            Message.receivedDeliveryConfirmation(messagingEvent);
          elsif (messagingEvent["postback"])
            Message.receivedPostback(messagingEvent);
          elsif (messagingEvent["read"])
            Message.receivedMessageRead(messagingEvent);
          elsif (messagingEvent["account_linking"])
            Message.receivedAccountLink(messagingEvent);
          else
            puts ("Webhook received unknown messagingEvent: #{messagingEvent}");
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
end
