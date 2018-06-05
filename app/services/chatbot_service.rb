# frozen_string_literal: true

class ChatbotService
  def self.receive messaging_event
    message = Parsers::MessageParser.parse(messaging_event)

    Rails.logger.info "Received at #{Time.at(message.timestamp/1000)} for user #{message.user_session_id} on page #{message.page_id} with message: #{message.value}"

    ::Bots::MessageWorker.perform_async(
      user_session_id: message.user_session_id,
      page_id: message.page_id,
      message: message.value)
  end

  def self.send_text session, text
    message_data = {
      'access_token' => session.bot.facebook_page_access_token,
      'recipient' => {
        'id' => session.user_session_id
      },
      'message' => {
        'text' => text,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      }
    }

    send_api(message_data)
  end

  def self.send_typing_on session
    message_data = {
      'access_token' => session.bot.facebook_page_access_token,
      'recipient' => {
        'id' => session.user_session_id
      },
      'sender_action' => 'typing_on'
    }

    send_api(message_data)
  end

  def self.send_question(session, question)
    return if question.nil?

    fb_params = question.to_fb_params(session.user_session_id)
    fb_params['access_token'] = session.bot.facebook_page_access_token
    
    send_api(fb_params)
  end

  private

  def self.send_api(message_data = {})
    request = Typhoeus::Request.new(
      'https://graph.facebook.com/v2.6/me/messages',
      method: :POST,
      body: 'this is a request body',
      params: message_data,
      headers: { Accept: 'application/json' }
    )

    request.run
  end
end
