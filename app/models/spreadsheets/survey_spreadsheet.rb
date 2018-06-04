class Spreadsheets::SurveySpreadsheet
  attr_reader :bot

  def initialize bot
    @bot = bot
  end

  def import sheet
    header = sheet.row(1)

    (2..sheet.last_row).each do |i|
      row = Hash[[header, sheet.row(i)].transpose]

      process row
    end
  end

  def process row
    return if row['type'].blank?

    # type can be 'text' or 'select_one gender'
    types = row['type'].split(' ')

    begin
      question = Parsers::QuestionParser.parse(types[0])
      question.update_attributes(bot_id: bot.id, select_name: types[1], name: row['name'], label: row['label'])

      question.add_relevant row['relevant']
    rescue
      Rails.logger.warn "Unknown datatype ##{types[0]}"
    end
  end
end
