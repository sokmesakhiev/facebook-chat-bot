# == Schema Information
#
# Table name: user_responses
#
#  id              :integer          not null, primary key
#  respondent_id   :integer
#  question_id     :integer
#  value           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Survey < ApplicationRecord
  belongs_to :respondent
  belongs_to :question

  validates :respondent, presence: true, on: :create
  validates :question, uniqueness: { scope: :respondent }

  after_create do
    UserResponseWorker.perform_at(30.seconds.from_now , id) if respondent.bot.authorized_spreadsheet?
  end
end
