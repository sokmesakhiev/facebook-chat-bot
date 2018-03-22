module Message
  SERVER_URL = FACEBOOK::CONFIG["serverURL"]
  def self.receivedMessage(event)
    senderID = event["sender"]["id"]
    recipientID = event["recipient"]["id"]
    timeOfMessage = event["timestamp"]
    message = event["message"]

    puts("Received message for user #{senderID} and page #{recipientID} at #{timeOfMessage} with message:")
    puts(message)

    isEcho = message["is_echo"]
    messageId = message["mid"]
    appId = message["app_id"]
    metadata = message["metadata"]

    messageText = message["text"]
    messageAttachments = message["attachments"]
    quickReply = message["quick_reply"]

    if isEcho
      sendResponseTextMessage(senderID, messageText)
      puts("Received echo for message #{messageId} and app #{appId} with metadata #{metadata}")
      return
    elsif quickReply
      quickReplyPayload = quickReply["payload"]
      puts("Quick reply for message #{messageId} with payload #{quickReplyPayload}")

      sendTextMessage(senderID, "Quick reply tapped")
      return
    end

    handle_message(messageText, senderID, recipientID)
  end

  def self.handle_message(messageText, user_session_id, page_id)
    sendTypingOn(user_session_id)

    if messageText
      survey = SurveyService.new(user_session_id, page_id)

      UserResponse.create(user_session_id: user_session_id, question_id: survey.current_question_id, value: messageText)

      return sendTextMessage(user_session_id, "Thank you!") if survey.last_question?

      callSendAPI(survey.next_question)
    else
      sendTextMessage(user_session_id, "Please kindly response :)!")
    end
  end

  def self.receivedPostback(event)
    user_session_id = event["sender"]["id"]
    page_id = event["recipient"]["id"]
    survey = SurveyService.new(user_session_id, page_id)
    payload = event["postback"]["payload"]

    sendTypingOn(user_session_id)

    return callSendAPI(survey.first_question) if payload == 'first_welcome'

    UserResponse.create(user_session_id: user_session_id, question_id: survey.current_question_id, value: payload)

    return sendTextMessage(user_session_id, "Thank you!") if survey.last_question?

    callSendAPI(survey.next_question)
  end

  def self.sendTextMessage(recipientId, messageText)
    messageData = {
      "recipient" => {
        "id" => recipientId
      },
      "message" => {
        "text" => messageText,
        "metadata" => "DEVELOPER_DEFINED_METADATA"
      }
    }

    callSendAPI(messageData)
  end

  def self.sendTypingOn(recipientId)
    puts("Turning typing indicator on")

    messageData = {
      "recipient" => {
        "id" => recipientId
      },
      "sender_action" => "typing_on"
    }

    callSendAPI(messageData)
  end


  def self.sendTypingOff(recipientId)
    puts("Turning typing indicator off")

    messageData = {
      "recipient" => {
        "id" => recipientId
      },
      "sender_action" => "typing_off"
    }

    callSendAPI(messageData)
  end

  def self.callSendAPI(messageData)
    messageData["access_token"] = FACEBOOK::CONFIG["pageAccessToken"]
    # request({
    #   uri: 'https://graph.facebook.com/v2.6/me/messages',
    #   qs: { access_token: FACEBOOK::CONFIG["pageAccessToken"] },
    #   method: 'POST',
    #   json: messageData,
    # })
    request = Typhoeus::Request.new(
      'https://graph.facebook.com/v2.6/me/messages',
      method: :POST,
      body: "this is a request body",
      params: messageData,
      headers: { Accept: "application/json" }
    )

    request.run
    response = request.response
    if(response.code == 200)
      result = JSON.parse response.response_body
      recipientId = result["recipient_id"]
      messageId = result["message_id"]
      if (messageId)
        puts "Successfully sent message with id #{messageId}to recipient #{recipientId}"
      else
        puts "Successfully called Send API for recipient #{recipientId}"
      end
    else
      puts ("Failed calling Send API #{response.code}")
    end
  end

  # def self.sendGenericTemplate(recipientId)
  #   messageData = {
  #     "recipient" => {
  #       "id "=> recipientId
  #     },
  #     "message" => {
  #       "attachment" => {
  #         "type" => "template",
  #         "payload" => {
  #           "template_type" => "generic",
  #           "elements" => [
  #              {
  #               "title" => "Sokmesa KHIEV",
  #               "image_url" => SERVER_URL + "/assets/mesa.jpg",
  #               "subtitle" => "Senior Software Developer",
  #               "default_action" => {
  #                 "type" => "web_url",
  #                 "url" => SERVER_URL + "/assets/mesa.jpg",
  #                 "messenger_extensions" => false,
  #                 "webview_height_ratio" => "TALL"
  #               },
  #               "buttons" => [{
  #                 "type" => "web_url",
  #                 "url" => "https://www.facebook.com/ksokmesa",
  #                 "title" => "Facebook"
  #               }, {
  #                 "type" => "phone_number",
  #                 "title" => "Phone Number",
  #                 "payload" => "+85512583587"
  #               }]
  #             }
  #           ]
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end


  # def self.sendImageMessage(recipientId)
  #   messageData = {
  #     "recipient"=> {
  #       "id"=> recipientId
  #     },
  #     "message"=> {
  #       "attachment"=> {
  #         "type"=> "image",
  #         "payload"=> {
  #           "url"=> SERVER_URL + "/assets/rift.png"
  #         }
  #       }
  #     }
  #   }
  #   puts messageData
  #   callSendAPI(messageData)
  # end


  # def self.sendGifMessage(recipientId)
  #   messageData = {
  #     "recipient"=> {
  #       "id"=> recipientId
  #     },
  #     "message"=> {
  #       "attachment"=> {
  #         "type"=> "image",
  #         "payload"=> {
  #           "url"=> SERVER_URL + "/assets/instagram_logo.gif"
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end


  # def self.sendAudioMessage(recipientId)
  #   messageData = {
  #     "recipient"=> {
  #       "id"=> recipientId
  #     },
  #     "message"=> {
  #       "attachment"=> {
  #         "type"=> "audio",
  #         "payload"=> {
  #           "url"=> SERVER_URL + "/assets/sample.mp3"
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end


  # def self.sendVideoMessage(recipientId)
  #   messageData = {
  #     "recipient"=> {
  #       "id"=> recipientId
  #     },
  #     "message"=> {
  #       "attachment"=> {
  #         "type"=> "video",
  #         "payload"=> {
  #           "url"=> SERVER_URL + "/assets/allofus480.mov"
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendFileMessage(recipientId)
  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" => {
  #       "attachment" => {
  #         "type" => "file",
  #         "payload" => {
  #           "url" => SERVER_URL + "/assets/test.txt"
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendResponseTextMessage(recipientId, messageText)
  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" => {
  #       "text" => "You have response " + messageText,
  #       "metadata" => "DEVELOPER_DEFINED_METADATA"
  #     }
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendButtonMessage(recipientId)
  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" => {
  #       "attachment" => {
  #         "type" => "template",
  #         "payload" => {
  #           "template_type" => "button",
  #           "text" => "This is test text from MESA",
  #           "buttons" =>[{
  #             "type" => "web_url",
  #             "url" => "https://www.oculus.com/en-us/rift/",
  #             "title" => "Open Web URL"
  #           }, {
  #             "type" => "postback",
  #             "title" => "Trigger Postback",
  #             "payload" => "DEVELOPER_DEFINED_PAYLOAD"
  #           }, {
  #             "type" => "phone_number",
  #             "title" => "Call Phone Number",
  #             "payload" => "+16505551234"
  #           }]
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendGenericMessage(recipientId)
  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" => {
  #       "attachment" => {
  #         "type" => "template",
  #         "payload" => {
  #           "template_type" => "generic",
  #           "elements" => [{
  #             "title" => "rift",
  #             "subtitle" => "Next-generation virtual reality",
  #             "item_url" => "https://www.oculus.com/en-us/rift/",
  #             "image_url" => SERVER_URL + "/assets/rift.png",
  #             "buttons" => [{
  #               "type" => "web_url",
  #               "url" => "https://www.oculus.com/en-us/rift/",
  #               "title" => "Open Web URL"
  #             }, {
  #               "type" => "postback",
  #               "title" => "Call Postback",
  #               "payload" => "Payload for first bubble",
  #             }],
  #           }, {
  #             "title" => "touch",
  #             "subtitle" => "Your Hands, Now in VR",
  #             "item_url" => "https://www.oculus.com/en-us/touch/",
  #             "image_url" => SERVER_URL + "/assets/touch.png",
  #             "buttons" => [{
  #               "type" => "web_url",
  #               "url" => "https://www.oculus.com/en-us/touch/",
  #               "title" => "Open Web URL"
  #             }, {
  #               "type" => "postback",
  #               "title" => "Call Postback",
  #               "payload" => "Payload for second bubble",
  #             }]
  #           }]
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendReceiptMessage(recipientId)
  #   receiptId = "order" + Math.floor(Math.random()*1000)

  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" =>{
  #       "attachment" => {
  #         "type" => "template",
  #         "payload" => {
  #           "template_type" => "receipt",
  #           "recipient_name" => "Peter Chang",
  #           "order_number" => receiptId,
  #           "currency" => "USD",
  #           "payment_method" => "Visa 1234",
  #           "timestamp" => "1428444852",
  #           "elements" => [{
  #             "title" => "Oculus Rift",
  #             "subtitle" => "Includes: headset, sensor, remote",
  #             "quantity" => 1,
  #             "price" => 599.00,
  #             "currency" => "USD",
  #             "image_url" => SERVER_URL + "/assets/riftsq.png"
  #           }, {
  #             "title" => "Samsung Gear VR",
  #             "subtitle" => "Frost White",
  #             "quantity" => 1,
  #             "price" => 99.99,
  #             "currency" => "USD",
  #             "image_url" => SERVER_URL + "/assets/gearvrsq.png"
  #           }],
  #           "address" => {
  #             "street_1" => "1 Hacker Way",
  #             "street_2" => "",
  #             "city" => "Menlo Park",
  #             "postal_code" => "94025",
  #             "state" => "CA",
  #             "country" => "US"
  #           },
  #           "summary" => {
  #             "subtotal" => 698.99,
  #             "shipping_cost" => 20.00,
  #             "total_tax" => 57.67,
  #             "total_cost" => 626.66
  #           },
  #           "adjustments" => [{
  #             "name" => "New Customer Discount",
  #             "amount" => -50
  #           }, {
  #             "name" => "$100 Off Coupon",
  #             "amount" => -100
  #           }]
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendQuickReply(recipientId)
  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" => {
  #       "text" => "What's your favorite movie genre?",
  #       "quick_replies" => [
  #         {
  #           "content_type" => "text",
  #           "title" => "Action",
  #           "payload" => "DEVELOPER_DEFINED_PAYLOAD_FOR_PICKING_ACTION"
  #         },
  #         {
  #           "content_type" => "text",
  #           "title" => "Comedy",
  #           "payload" => "DEVELOPER_DEFINED_PAYLOAD_FOR_PICKING_COMEDY"
  #         },
  #         {
  #           "content_type" => "text",
  #           "title" => "Drama",
  #           "payload" => "DEVELOPER_DEFINED_PAYLOAD_FOR_PICKING_DRAMA"
  #         }
  #       ]
  #     }
  #   }

  #   callSendAPI(messageData)
  # end


  # def self.sendReadReceipt(recipientId)
  #   puts("Sending a read receipt to mark message as seen")

  #   messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "sender_action" => "mark_seen"
  #   }

  #   callSendAPI(messageData)
  # end

  # def self.sendAccountLinking(recipientId)
  #   return messageData = {
  #     "recipient" => {
  #       "id" => recipientId
  #     },
  #     "message" => {
  #       "attachment" => {
  #         "type" => "template",
  #         "payload" => {
  #           "template_type" => "button",
  #           "text" => "Welcome. Link your account.",
  #           "buttons" =>[{
  #             "type" => "account_link",
  #             "url" => SERVER_URL + "/authorize"
  #           }]
  #         }
  #       }
  #     }
  #   }

  #   callSendAPI(messageData)
  # end
end
