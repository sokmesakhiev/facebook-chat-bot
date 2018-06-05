# frozen_string_literal: true

class SurveyService
  attr_accessor :session

  def initialize(session)
    @session = session
    @bot_state = BotState.new(session.bot)
    @question_user = QuestionUser.find_or_create_by(user_session_id: session.user_session_id, bot_id: session.bot.id)
  end

  def save_current_response
    session.bot.user_responses.create(user_session_id: session.user_session_id, question_id: @question_user.current_question_id, value: session.response_text)
  end

  def start
    save_state(first_question)
    ChatbotService.send_question(session, first_question)
  end

  def first_question
    @bot_state.first
  end

  def move_next
    ChatbotService.send_typing_on(session)

    return start if session.response_text == Question::QUESTION_FIRST_WELCOME

    save_current_response

    return finish if last_question? || next_question.nil?

    save_state(next_question)
    ChatbotService.send_question(session, next_question)
  end

  def next_question
    @nex_question ||= next_quiz
  end

  def last_question?
    @question_user.current_question_id.present? && @bot_state.last?(@question_user.current_question_id)
  end

  def finish
    reply_msg = 'Thank you!'
    if session.bot.has_aggregate?
      aggregation = session.bot.get_aggregation(session.bot.scoring_of(session.user_session_id))
      
      reply_msg = aggregation.result if aggregation
    end

    ChatbotService.send_text(session, reply_msg)
  end

  private

  def next_quiz(question_id = nil)
    current = nil

    if question_id.present? || @question_user.current_question_id.present?
      current = @bot_state.find_current_index(question_id || @question_user.current_question_id)
    end

    question = @bot_state.next(current: current)

    return next_quiz(question.id) if skip_question(question)

    question
  end

  def skip_question(question)
    return false if question.nil? || !question.has_relevant?

    user_response = UserResponse.where(user_session_id: session.user_session_id, question_id: question.relevant.id).last

    return true if user_response.nil?

    if question.operator == 'selected'
      arr = user_response.value.split(',')
      return !arr.include?(question.relevant_value)
    end

    condition = eval("user_response.value #{question.operator} question.relevant_value")
    !condition
  end

  def save_state(question)
    @question_user.update_attribute(:current_question_id, question['id'])
  end
end
