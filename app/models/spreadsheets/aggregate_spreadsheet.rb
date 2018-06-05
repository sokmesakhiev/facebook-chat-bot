class Spreadsheets::AggregateSpreadsheet
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
    return if row['score_from'].blank? || row['score_to'].blank?

    begin
      Aggregation.create!(row.merge(bot: bot))
    rescue ex
      Rails.logger.warn ex.message
    end
  end
end
