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
end
