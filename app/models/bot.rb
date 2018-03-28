# == Schema Information
#
# Table name: bots
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  facebook_page_id           :string(255)
#  facebook_page_access_token :string(255)
#  google_access_token        :string(255)
#  google_token_expires_at    :string(255)
#  google_refresh_token       :string(255)
#  google_spreadsheet_key     :string(255)
#  google_spreadsheet_title   :string(255)
#

class Bot < ApplicationRecord
  has_many :questions, dependent: :destroy
  belongs_to :user

  validates :name, presence: true

  def import(file)
    xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
    self.questions.destroy_all

    import_questions(xlsx)
    import_choices(xlsx)

    BotWorker.perform_async(self.id)
  end

  def authorized_spreadsheet?
    self.google_access_token.present? && self.google_spreadsheet_key.present?
  end

  private

  def import_questions(xlsx)
    spreadsheet = xlsx.sheet('survey')
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      next if row['type'].blank?

      types = row['type'].split(' ')
      question = self.questions.create!(
        question_type: types[0],
        select_name: types[1],
        name: row['name'],
        label: row['label'])
      handle_relevant_field(question, row['relevant'])
    end
  end

  def handle_relevant_field(question, relevant)
    return if relevant.blank?

    relevant_field = relevant[/\$\{(\w+)\}/, 1]
    params = {
      relevant_id: self.questions.find_by(name: relevant_field).id,
      operator: relevant[/(\>\=|\<\=|\!\=|[\+\-\*\>\<\=\|]|div|or|and|mod|selected)/, 1],
      relevant_value: relevant[/[\‘\'\"](\w+)[\’\'\"]/, 1]
    }
    params[:operator] = '==' if params[:operator] == '='

    question.update_attributes(params)
  end

  def import_choices(xlsx)
    spreadsheet = xlsx.sheet('choices')
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      question = self.questions.find_by(select_name: row['list_name'])
      next if row['list_name'].blank? || question.nil?

      row.delete('list_name')
      question.choices.create!(row)
    end
  end
end
