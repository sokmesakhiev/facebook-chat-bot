module Bots
  class ImportHeaderWorker
    include Sidekiq::Worker

    def perform(bot_id)
      bot = Bot.find(bot_id)

      return if bot.nil? || bot.questions.blank? || !bot.authorized_spreadsheet?

      ws = BotDriveService.new(bot).worksheets[0]
      ws[1, 1] = 'user_session_id'

      bot.questions.each_with_index do |question, index|
        ws[1, index + 2] = question.name
      end

      ws.save
    end
  end
end
