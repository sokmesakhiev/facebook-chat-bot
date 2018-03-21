# == Schema Information
#
# Table name: user_responses
#
#  id              :integer          not null, primary key
#  user_session_id :string(255)
#  question_id     :integer
#  value           :string(255)
#

class UserResponse < ApplicationRecord
  belongs_to :question

  after_create do
    UserResponseWorker.perform_async(self.id)
  end
end
