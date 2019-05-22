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
#  restart_msg                :string(255)
#  greeting_msg               :text
#

class Bot < ApplicationRecord
  belongs_to :user

  has_many :questions, dependent: :destroy
  has_many :aggregations, dependent: :destroy
  has_many :respondents, dependent: :nullify

  validates :name, presence: true

  DEFAULT_RESTART_MSG = 'Do you want to restart this survey again?'
  DEFAULT_GREETING_MSG = 'Thank for your time to take basic mental health test. Please try again in next 3 months.'

  def import(file)
    return unless File.exists? file.path

    questions.destroy_all
    aggregations.destroy_all
    FileParser.for(self).import(file)

    Bots::ImportHeaderWorker.perform_async(id)
  end

  def authorized_spreadsheet?
    google_access_token.present? && google_spreadsheet_key.present?
  end

  def authorized_facebook?
    facebook_page_id.present? && facebook_page_access_token.present?
  end

  def has_question?
    bot.questions.size > 0
  end

  def first_question? question
    find_current_index_of == 0
  end

  def question_of(question_index)
    return nil if question_index < 0 || question_index >= questions.length

    questions[question_index]
  end

  def next_question_of(question)
    next_question_index = find_current_index_of(question) + 1

    question_of(next_question_index)
  end

  def find_current_index_of(question)
    return -1 if question.nil?

    questions.index { |q| q.id == question.id }
  end

  def has_aggregate?
    aggregations.size > 0
  end

  def get_aggregation score
    aggregations.where("score_from <= :score and score_to >= :score", score: score).first
  end

  def scorable_questionnaires
    questions.where(type: [Questions::SelectOneQuestion.name, Questions::SelectMultipleQuestion.name])
  end

  def clean_dependency_media
    FileUtils.remove_dir("public/upload/survey/bot_#{id}",true)
  end

end
