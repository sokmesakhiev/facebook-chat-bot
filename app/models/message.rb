module Message
  def self.received_message(event)
    sender_id = event['sender']['id']
    recipient_id = event['recipient']['id']
    time_of_message = event['timestamp']
    message = event['message']

    puts("Received message for user #{sender_id} and page #{recipient_id} at #{time_of_message} with message:")
    puts(message)

    ::Bots::MessageWorker.perform_async(:response_message,
                                        user_session_id: sender_id,
                                        page_id: recipient_id,
                                        message: message['text'])
  end

  def self.received_postback(event)
    ::Bots::MessageWorker.perform_async(:response_postback,
                                        user_session_id: event['sender']['id'],
                                        page_id: event['recipient']['id'],
                                        message: event['postback']['payload'])
  end
end
