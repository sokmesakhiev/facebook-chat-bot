# == Schema Information
#
# Table name: question_users
#
#  id                  :integer          not null, primary key
#  user_session_id     :string(255)
#  current_question_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class QuestionUser < ApplicationRecord
  belongs_to :question, foreign_key: :current_question_id
end
