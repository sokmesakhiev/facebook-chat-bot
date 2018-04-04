module Message
  SERVER_URL = FACEBOOK::CONFIG['serverURL']
  def self.received_message(event)
    sender_id = event['sender']['id']
    recipient_id = event['recipient']['id']
    time_of_message = event['timestamp']
    message = event['message']

    puts("Received message for user #{sender_id} and page #{recipient_id} at #{time_of_message} with message:")
    puts(message)

    if message['is_echo']
      send_response_text_message(sender_id, recipient_id, message['text'])
      puts("Received echo for message #{message['mid']} and app #{message['app_id']} with metadata #{message['metadata']}")
      return
    elsif message['quick_reply'].present?
      puts("Quick reply for message #{message['mid']} with payload #{message['quick_reply']['payload']}")

      send_text_message(sender_id, recipient_id, 'Quick reply tapped')
      return
    end

    handle_message(message['text'], sender_id, recipient_id)
  end

  def self.handle_message(message_text, user_session_id, page_id)
    return if message_text.blank?

    survey = SurveyService.new(user_session_id, page_id)

    return if survey.bot.nil? || !survey.bot.published?

    send_typing_on(user_session_id, page_id)
    survey.update_response(message_text)

    if survey.last_question? || survey.next_question.nil?
      return send_text_message(user_session_id, page_id, 'Thank you!')
    end

    survey.update_state(survey.next_question)
    call_send_api(survey.template_message(survey.next_question))
  end

  def self.received_postback(event)
    user_session_id = event['sender']['id']
    page_id = event['recipient']['id']
    payload = event['postback']['payload']
    survey = SurveyService.new(user_session_id, page_id)

    return if survey.bot.nil? || !survey.bot.published?

    send_typing_on(user_session_id, page_id)

    if payload == 'first_welcome'
      survey.update_state(survey.first_question)
      return call_send_api(survey.template_message(survey.first_question))
    end

    survey.update_response(payload)

    if survey.last_question? || survey.next_question.nil?
      return send_text_message(user_session_id, page_id, 'Thank you!')
    end

    survey.update_state(survey.next_question)
    call_send_api(survey.template_message(survey.next_question))
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
end
