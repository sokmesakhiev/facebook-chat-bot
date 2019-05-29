class FileUtil
  def self.image_url(bot, file_name)
    "#{ENV['HOST']}/upload/survey/bot_#{bot.id}/#{file_name}"
  end

end
