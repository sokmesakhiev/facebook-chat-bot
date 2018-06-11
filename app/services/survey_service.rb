# frozen_string_literal: true

class SurveyService
  attr_accessor :session

  def initialize(session)
    @session = session
  end

  def move_next
    session.send_typing_on

    current_quiz = get_user_state.question

    save_current_response current_quiz

    next_quiz = next_question current_quiz

    finish if next_quiz.nil?

    save_state next_quiz

    session.send_question next_quiz
  end

  protected

  def next_question(question = nil)
    next_quiz = session.bot.next_question_of(question)

    return next_question(next_quiz) if skip_question(next_quiz)

    next_quiz
  end

  def skip_question(question)
    return false if question.nil? || !question.has_relevant?

    user_response = UserResponse.where(bot_id: session.bot.id, user_session_id: session.user_session_id, question_id: question.relevant.id).last

    return true if user_response.nil?

    if question.operator == 'selected'
      arr = user_response.value.split(',')
      return !(arr.include?(question.relevant_value) || arr.include?(question.relevant.value_of(question.relevant_value)))
    end

    condition = eval("user_response.value #{question.operator} question.relevant_value")
    condition = eval("user_response.value #{question.operator} question.relevant.value_of(question.relevant_value)") unless condition

    !condition
  end

  def finish
    session.terminate
  end

  def save_current_response question
    return if question.nil?

    session.bot.user_responses.create(user_session_id: session.user_session_id, question_id: question.id, value: session.response_text)
  end

  def save_state(question)
    return if question.nil?

    versioning = get_user_state.versioning.nil? ? Time.now.to_i : get_user_state.versioning

    get_user_state.update_attribute(:current_question_id, question.id, versioning: versioning)
  end

  def get_user_state
    @question_user ||= QuestionUser.find_or_create_by(user_session_id: session.user_session_id, bot_id: session.bot.id)
  end
end
