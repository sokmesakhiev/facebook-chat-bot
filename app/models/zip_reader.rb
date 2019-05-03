require 'rubygems'
require 'zip'
require 'fileutils'

class ZipReader

  attr_accessor :bot

  def self.for(bot)
    new(bot)
  end

  def initialize(bot)
    @bot = bot
  end

  def import(file_path)
    spreadsheet_file = extract_file(file_path).select{ |file| survey_file?(file.name) }.first
    import_spreadsheet(spreadsheet_file.name)
  end

  def import_spreadsheet(file_name)
    file_path = "#{destination_directory_path}/#{File.basename(file_name)}"
    file_type = File.extname(file_path)[1..-1]
    BotSpreadsheet.for(bot).import(file_path, file_type)
  end

  def extract_file(file_path)
    extracted_files = []
    Zip::File.open(file_path) do |zip_file|
      extracted_files = whitelist_files(zip_file).each do |file|
        file_name = File.basename(file.name)
        destination_file_path = destination_file_path(file_name)
        file.extract(destination_file_path) {true}
      end
    end
    return extracted_files
  end

  def destination_file_path(origin_file)
    "#{destination_directory_path}/#{origin_file}"
  end

  def destination_directory_path
    dirname = "#{Rails.root}/public/upload/survey/bot_#{bot.id}"
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end

    return dirname
  end

  def whitelist_files(files)
    files = files.select(&:file?)
    files.reject!{|f| f.name =~ /\.DS_Store|__MACOSX|(^|\/)\._/ }
    raise "Invalid survey file" unless files.any?{|f| survey_file?(f.name) }

    files.select!{|f| whitelist_file?(File.basename(f.name))}
    return files
  end

  def whitelist_file?(file_name)
    return true if survey_file?(file_name) || media_file?(file_name)
    return false
  end

  def survey_file?(file_name)
    File.basename(file_name) =~ /\A#{ENV['SAMPLE_XLS_FILE_NAME']}.xlsx?\z/
  end

  def media_file?(file_name)
    File.basename(file_name) =~ /.\.(png|jpeg|jpg|gif)$/
  end
end
