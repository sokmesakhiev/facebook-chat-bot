# frozen_string_literal: true

class SurveyService
  attr_accessor :user_session_id, :facebook_page_id

  def initialize(user_id, page_id)
    @user_session_id = user_id
    @facebook_page_id = page_id
    @question_user = QuestionUser.find_or_create_by(user_session_id: user_id)
    @bot = Bot.find_by(facebook_page_id: page_id)
    @bot_state = BotState.new(@bot)
  end

  def first_question
    @bot_state.first
  end

  def save_state(question)
    @question_user.update_attribute(:current_question_id, question['id'])
  end

  def save_response(response_message)
    UserResponse.create(user_session_id: user_session_id, question_id: @question_user.current_question_id, value: response_message)
  end

  def next_question
    @nex_question ||= next_q
  end

  def last_question?
    @question_user.current_question_id.present? && @bot_state.last?(@question_user.current_question_id)
  end

  private

  def next_q(question_id = nil)
    current = nil

    if question_id.present? || @question_user.current_question_id.present?
      current = @bot_state.find_current_index(question_id || @question_user.current_question_id)
    end

    question = @bot_state.next(current: current)

    return next_q(question.id) if question.present? && question.relevant.present? && skip_question(question)

    question
  end

  def skip_question(question)
    user_response = UserResponse.where(user_session_id: user_session_id, question_id: question.relevant.id).last

    return true if user_response.nil?

    if question.operator == 'selected'
      arr = user_response.value.split(',')
      return !arr.include?(question.relevant_value)
    end

    condition = eval("user_response.value #{question.operator} question.relevant_value")
    !condition
  end
end
