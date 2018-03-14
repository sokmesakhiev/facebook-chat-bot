# == Schema Information
#
# Table name: bots
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class Bot < ApplicationRecord
  has_many :questions, dependent: :destroy

  def import(file)
    xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
    # self.surveys.destroy_all

    import_surveys(xlsx)
    import_choices(xlsx)
  end

  private

  def import_surveys(xlsx)
    spreadsheet = xlsx.sheet('survey')
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      next if row['type'].blank?

      arr = row['type'].split(' ')
      self.surveys.create!(question_type: arr[0], name: arr[1] || row['name'], label: row['label'])
    end
  end

  def import_choices(xlsx)
    spreadsheet = xlsx.sheet('choices')
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      survey = self.surveys.find_by(name: row['list_name'])
      next if survey.nil?

      survey.choices.create!(name: row['name'], label: row['label'])
    end
  end
end
