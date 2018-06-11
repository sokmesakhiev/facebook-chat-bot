# == Schema Information
#
# Table name: user_responses
#
#  id              :integer          not null, primary key
#  user_session_id :string(255)
#  question_id     :integer
#  value           :string(255)
#  version         :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserResponse < ApplicationRecord
  belongs_to :question
  belongs_to :bot

  validates :version, presence: true
  validates :bot, presence: true, on: :create
  validates :question, :uniqueness => {:scope => [:user_session_id, :version]}

  after_create do
    UserResponseWorker.perform_at(30.seconds.from_now , id) if bot.authorized_spreadsheet?
  end
end
