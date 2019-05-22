class BotSpreadsheet
  attr_reader :bot

  def initialize bot
    @bot = bot
  end

  def import(file_path, file_type)
    spreadsheet(file_path, file_type).each_with_pagename do |sheet_name, sheet|
      begin
        get(sheet_name).import(sheet)
      rescue
        Rails.logger.warn "unknown handler for sheet: #{sheet_name}"
      end
    end
  end

  def get sheet_name
    "Spreadsheets::#{sheet_name.camelcase}Spreadsheet".constantize.new(bot)
  end

  def self.for(bot)
    new(bot)
  end

  private

  def spreadsheet file_path, file_type
    Roo::Spreadsheet.open(file_path, extension: file_type.to_sym)
  end
end
