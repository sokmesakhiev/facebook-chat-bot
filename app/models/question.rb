# == Schema Information
#
# Table name: questions
#
#  id              :integer          not null, primary key
#  bot_id          :integer
#  question_type   :string(255)
#  select_name     :string(255)
#  name            :string(255)
#  label           :string(255)
#  dependent_id    :integer
#  operator        :string(255)
#  dependent_value :string(255)
#

class Question < ApplicationRecord
  belongs_to :bot
  has_many :choices, dependent: :destroy
  has_many :question_users, foreign_key: :current_question_id, dependent: :destroy
  has_many :user_responses, dependent: :destroy

  validates :name, uniqueness: { scope: :bot_id }
end
