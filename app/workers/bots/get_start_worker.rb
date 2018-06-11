module Bots
  class GetStartWorker
    include Sidekiq::Worker

    def perform(bot_id)
      bot = Bot.find(bot_id)

      return if bot.nil? || bot.questions.blank? || !bot.authorized_spreadsheet?

      request = Typhoeus::Request.new(
        'https://graph.facebook.com/v2.6/me/messenger_profile',
        method: :POST,
        body: { "get_started": { "payload": Question::QUESTION_GET_STARTED } },
        params: { access_token: bot.facebook_page_access_token },
        headers: { Accept: 'application/json' }
      )

      request.run
    end
  end
end
