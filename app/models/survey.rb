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
end
