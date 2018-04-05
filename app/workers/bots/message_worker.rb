module Bots
  class MessageWorker
    include Sidekiq::Worker

    def perform(action, options = {})
      user_session_id = options['user_session_id']
      page_id = options['page_id']
      message = options['message']
      bot = Bot.find_by(facebook_page_id: page_id)

      return if bot.nil? || !bot.published? || bot.questions.blank?

      MessageService.new(user_session_id, page_id, message).send(action)
    end
  end
end