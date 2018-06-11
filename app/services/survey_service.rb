# frozen_string_literal: true

class SurveyService
  attr_accessor :session

  def initialize(session)
    @session = session
  end

  def move_next
    session.send_typing_on

    question_user = get_user_state session

    current_quiz = question_user.question
    version = question_user.version

    save_current_response current_quiz, version

    next_quiz = next_question current_quiz

    finish(version) if next_quiz.nil?

    question_user.save_state next_quiz

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

  def finish version
    session.terminate version
  end

  def save_current_response question, version
    return if question.nil?

    session.bot.user_responses.create(user_session_id: session.user_session_id, question_id: question.id, value: session.response_text, version: version)
  end

  def get_user_state session
    if session.response_text == Question::QUESTION_GET_STARTED
      question_user = QuestionUser.renew session, Time.now.to_i
    else
      question_user = QuestionUser.state_of(session)
      # restart user state when user finish survey but still keep sending message
      question_user = QuestionUser.renew session, Time.now.to_i if question_user.nil?
    end

    question_user
  end
end
