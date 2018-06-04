class Spreadsheets::ChoicesSpreadsheet
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
    question = Question.where(bot_id: bot.id).find_by(select_name: row['list_name'])

    return if row['list_name'].blank? || question.nil?

    row.delete('list_name')

    question.choices.create!(row)
  end
end
