# == Schema Information
#
# Table name: bots
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  user_id                    :integer
#  facebook_page_id           :string(255)
#  facebook_page_access_token :string(255)
#  google_access_token        :string(255)
#  google_token_expires_at    :datetime
#  google_refresh_token       :string(255)
#  google_spreadsheet_key     :string(255)
#  google_spreadsheet_title   :string(255)
#  published                  :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

class Bot < ApplicationRecord
  has_many :questions, dependent: :destroy
  belongs_to :user

  validates :name, presence: true

  def import(file)
    xlsx = Roo::Spreadsheet.open(file.path, extension: :xlsx)
    questions.destroy_all

    import_questions(xlsx)
    import_choices(xlsx)

    Bots::ImportHeaderWorker.perform_async(id)
  end

  def authorized_spreadsheet?
    google_access_token.present? && google_spreadsheet_key.present?
  end

  def authorized_facebook?
    facebook_page_id.present? && facebook_page_access_token.present?
  end

  private

  def import_questions(xlsx)
    spreadsheet = xlsx.sheet('survey')
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      next if row['type'].blank?

      types = row['type'].split(' ')

      begin
        question = Parsers::QuestionParser.parse(types[0])
        question.update_attributes(bot_id: id, select_name: types[1], name: row['name'], label: row['label'])

        handle_relevant_field(question, row['relevant'])

      rescue
        Rails.logger.warn "Unknown datatype ##{types[0]}"
      end
    end
  end

  def handle_relevant_field(question, relevant)
    return if relevant.blank?

    relevant_field = relevant[/\$\{(\w+)\}/, 1]
    params = {
      relevant_id: questions.find_by(name: relevant_field).id,
      operator: relevant[/(\>\=|\<\=|\!\=|[\+\-\*\>\<\=\|]|div|or|and|mod|selected)/, 1],
      relevant_value: relevant[/[‘|'|"](\w+)[’|'|"]/, 1]
    }
    params[:operator] = '==' if params[:operator] == '='

    question.update_attributes(params)
  end

  def import_choices(xlsx)
    spreadsheet = xlsx.sheet('choices')
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      question = questions.find_by(select_name: row['list_name'])
      next if row['list_name'].blank? || question.nil?

      row.delete('list_name')
      question.choices.create!(row)
    end
  end

end
