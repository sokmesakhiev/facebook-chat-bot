# == Schema Information
#
# Table name: surveys
#
#  id            :integer          not null, primary key
#  question_id   :integer
#  value         :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  respondent_id :integer
#

class Survey < ApplicationRecord
  belongs_to :respondent
  belongs_to :question

  validates :respondent, presence: true, on: :create
  validates :question, uniqueness: { scope: :respondent }

  after_create do
    UserResponseWorker.perform_at(30.seconds.from_now , id) if respondent.bot.authorized_spreadsheet?
  end

  def self.score_of respondent, questions
    where(question_id: questions.select(&:id), respondent: respondent).sum(:value)
  end

  def self.last_response respondent, question
    where(respondent: respondent, question: question).last
  end

  def self.matched? respondent, expression
    matches = false

    expression.conditions.each do |condition|
      relevant_question = Question.find_by(bot_id: respondent.bot.id, name: condition.field)
      
      matches = relevant_question.matched?(respondent, condition) if relevant_question
      
      return matches if (matches == expression.exit_value)
    end

    matches
  end

end
