class FileParser
  attr_reader :bot

  def initialize bot
    @bot = bot
  end

  def self.for(bot)
    new(bot)
  end

  def import(file)
    file_type = File.extname(file.original_filename)[1..-1]
    case file_type
    when "zip"
      ZipReader.for(bot).import(file.path)
    when /xlsx?/
      BotSpreadsheet.for(bot).import(file.path, file_type)
    else
      raise "unsupport type"
    end
  end

end
