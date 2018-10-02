# == Schema Information
#
# Table name: session_states
#
#  id                  :integer          not null, primary key
#  user_session_id     :string(255)
#  current_question_id :integer
#  bot_id              :integer
#  version             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  state     ..........:string(255)
#

class Respondent < ApplicationRecord
  belongs_to :question, foreign_key: :current_question_id
  belongs_to :bot
  has_many :surveys

  validates :question, presence: true, on: :create
  validates :bot, presence: true, on: :create
  validates :version, presence: true


  STATE_COMPLETED = :completed

  def save_state question
    return if question.nil?

    update_attributes current_question_id: question.id
  end

  def self.find_last session
    where(user_session_id: session.user_session_id, bot_id: session.bot.id).last
  end

  def self.instance_of session
    create user_session_id: session.user_session_id, bot_id: session.bot.id, version: Time.now.to_i
  end

  def completed?
    state == STATE_COMPLETED.to_s
  end

end
