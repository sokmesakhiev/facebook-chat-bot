module Message
  SERVER_URL = FACEBOOK::CONFIG['serverURL']
  def self.received_message(event)
    sender_id = event['sender']['id']
    recipient_id = event['recipient']['id']
    time_of_message = event['timestamp']
    message = event['message']

    puts("Received message for user #{sender_id} and page #{recipient_id} at #{time_of_message} with message:")
    puts(message)

    is_echo = message['is_echo']
    message_id = message['mid']
    app_id = message['app_id']
    metadata = message['metadata']

    message_text = message['text']
    # message_attachments = message['attachments']
    quick_reply = message['quick_reply']

    if is_echo
      send_response_text_message(sender_id, recipient_id, message_text)
      puts("Received echo for message #{message_id} and app #{app_id} with metadata #{metadata}")
      return
    elsif quick_reply
      quick_reply_payload = quick_reply['payload']
      puts("Quick reply for message #{message_id} with payload #{quick_reply_payload}")

      send_text_message(sender_id, recipient_id, 'Quick reply tapped')
      return
    end

    handle_message(message_text, sender_id, recipient_id)
  end

  def self.handle_message(message_text, user_session_id, page_id)
    send_typing_on(user_session_id, page_id)

    if message_text
      survey = SurveyService.new(user_session_id, page_id)

      return if survey.bot.nil? || !survey.bot.published?

      UserResponse.create(user_session_id: user_session_id, question_id: survey.current_question_id, value: message_text)

      return send_text_message(user_session_id, page_id, 'Thank you!') if survey.last_question?

      call_send_api(survey.next_question)
    else
      send_text_message(user_session_id, page_id, 'Please kindly response :)!')
    end
  end

  def self.received_postback(event)
    user_session_id = event['sender']['id']
    page_id = event['recipient']['id']
    survey = SurveyService.new(user_session_id, page_id)

    return if survey.bot.nil? || !survey.bot.published?

    payload = event['postback']['payload']

    send_typing_on(user_session_id, page_id)

    return call_send_api(survey.first_question) if payload == 'first_welcome'

    UserResponse.create(user_session_id: user_session_id, question_id: survey.current_question_id, value: payload)

    return send_text_message(user_session_id, page_id, 'Thank you!') if survey.last_question?

    call_send_api(survey.next_question)
  end

  def self.send_text_message(recipient_id, page_id, message_text)
    bot = Bot.find_by(facebook_page_id: page_id)

    return if bot.nil? || !bot.published?

    message_data = {
      'recipient' => {
        'id' => recipient_id
      },
      'message' => {
        'text' => message_text,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      },
      'access_token' => bot.facebook_page_access_token
    }

    call_send_api(message_data)
  end

  def self.send_typing_on(recipient_id, page_id)
    bot = Bot.find_by(facebook_page_id: page_id)

    return if bot.nil? || !bot.published?

    message_data = {
      'recipient' => {
        'id' => recipient_id
      },
      'sender_action' => 'typing_on',
      'access_token' => bot.facebook_page_access_token
    }

    call_send_api(message_data)
  end

  def self.send_typing_off(recipient_id, page_id)
    bot = Bot.find_by(facebook_page_id: page_id)

    return if bot.nil? || !bot.published?

    message_data = {
      'recipient' => {
        'id' => recipient_id
      },
      'sender_action' => 'typing_off',
      'access_token' => bot.facebook_page_access_token
    }

    call_send_api(message_data)
  end

  def self.send_response_text_message(recipient_id, page_id, message_text)
    bot = Bot.find_by(facebook_page_id: page_id)

    return if bot.nil? || !bot.published?

    message_data = {
      'recipient' => {
        'id' => recipient_id
      },
      'message' => {
        'text' => 'You have response ' + message_text,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      },
      'access_token' => bot.facebook_page_access_token
    }

    call_send_api(message_data)
  end

  def self.call_send_api(message_data)
    request = Typhoeus::Request.new(
      'https://graph.facebook.com/v2.6/me/messages',
      method: :POST,
      body: 'this is a request body',
      params: message_data,
      headers: { Accept: 'application/json' }
    )

    request.run
    response = request.response
    if response.code == 200
      result = JSON.parse response.response_body
      recipient_id = result['recipient_id']
      message_id = result['message_id']
      if message_id
        puts "Successfully sent message with id #{message_id}to recipient #{recipient_id}"
      else
        puts "Successfully called Send API for recipient #{recipient_id}"
      end
    else
      puts "Failed calling Send API #{response.code}"
    end
  end

  # def self.sendGenericTemplate(recipient_id)
  #   message_data = {
  #     "recipient" => {
  #       "id "=> recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendImageMessage(recipient_id)
  #   message_data = {
  #     "recipient"=> {
  #       "id"=> recipient_id
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
  #   puts message_data
  #   call_send_api(message_data)
  # end

  # def self.sendGifMessage(recipient_id)
  #   message_data = {
  #     "recipient"=> {
  #       "id"=> recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendAudioMessage(recipient_id)
  #   message_data = {
  #     "recipient"=> {
  #       "id"=> recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendVideoMessage(recipient_id)
  #   message_data = {
  #     "recipient"=> {
  #       "id"=> recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendFileMessage(recipient_id)
  #   message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendButtonMessage(recipient_id)
  #   message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendGenericMessage(recipient_id)
  #   message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendReceiptMessage(recipient_id)
  #   receiptId = "order" + Math.floor(Math.random()*1000)

  #   message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendQuick_reply(recipient_id)
  #   message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
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

  #   call_send_api(message_data)
  # end

  # def self.sendReadReceipt(recipient_id)
  #   puts("Sending a read receipt to mark message as seen")

  #   message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
  #     },
  #     "sender_action" => "mark_seen"
  #   }

  #   call_send_api(message_data)
  # end

  # def self.sendAccountLinking(recipient_id)
  #   return message_data = {
  #     "recipient" => {
  #       "id" => recipient_id
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

  #   call_send_api(message_data)
  # end
end
