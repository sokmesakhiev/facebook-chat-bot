# frozen_string_literal: true

class SurveyService
  attr_accessor :session

  def initialize(session)
    @session = session
  end

  def move_next
    session.send_typing_on

    respondent = get_respondent session

    current_quiz = respondent.question

    save_current_response respondent, current_quiz, session.response_text

    next_quiz = next_question respondent, current_quiz

    finish(respondent) if next_quiz.nil?

    respondent.save_state next_quiz

    session.send_question next_quiz
  end

  protected

  def next_question(respondent, question = nil)
    next_quiz = session.bot.next_question_of(question)

    return next_question(respondent, next_quiz) if skip_question(respondent, next_quiz)

    next_quiz
  end

  def skip_question(respondent, question)
    return false if question.nil? || !question.has_relevant?

    user_response = Survey.where(respondent: respondent, question: question.relevant).last

    return true if user_response.nil?

    if question.operator == 'selected'
      arr = user_response.value.split(',')
      return !(arr.include?(question.relevant_value) || arr.include?(question.relevant.value_of(question.relevant_value)))
    end

    condition = eval("user_response.value #{question.operator} question.relevant_value")
    condition = eval("user_response.value #{question.operator} question.relevant.value_of(question.relevant_value)") unless condition

    !condition
  end

  def finish respondent
    session.terminate respondent
  end

  def save_current_response respondent, question, answer
    return if question.nil?

    respondent.surveys.create(question: question, value: answer)
  end

  def get_respondent session
    if session.response_text == Question::QUESTION_GET_STARTED
      respondent = Respondent.instance_of session
    else
      respondent = Respondent.find_last(session)
      # restart user respondent state when user completed the survey but still keep sending message
      respondent = Respondent.instance_of session if (respondent.nil? or respondent.completed?)
    end

    respondent
  end
end
