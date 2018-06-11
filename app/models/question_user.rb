# == Schema Information
#
# Table name: question_users
#
#  id                  :integer          not null, primary key
#  user_session_id     :string(255)
#  current_question_id :integer
#  bot_id              :integer
#  version             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class QuestionUser < ApplicationRecord
  belongs_to :question, foreign_key: :current_question_id
  belongs_to :bot

  def self.state_of session
    find_by(user_session_id: session.user_session_id, bot_id: session.bot.id)
  end

  def self.clean(session)
    where(user_session_id: session.user_session_id, bot_id: session.bot.id).destroy_all
  end

  def self.renew session, version
    clean(session)

    state = state_of session

    state = new(user_session_id: session.user_session_id, bot_id: session.bot.id) if state.nil?
    state.version = version
    state.save

    state
  end

  def save_state question
    return if question.nil?

    update_attributes current_question_id: question.id
  end

end
