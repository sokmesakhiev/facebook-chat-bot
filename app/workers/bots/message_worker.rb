module Bots
  class MessageWorker
    include Sidekiq::Worker

    def perform(options = {})
      user_session_id = options['user_session_id']
      page_id = options['page_id']
      text = options['message']
      bot = Bot.find_by(facebook_page_id: page_id)

      return if bot.nil? || !bot.published? || bot.questions.blank?

      session = Facebook::Session.new(user_session_id, page_id, text)
      SurveyService.new(session).move_next
    end
  end
end
