# frozen_string_literal: true

class SurveyService
  attr_accessor :session

  def initialize(session)
    @session = session
  end

  #TODO REFACTOR to remove this too complicate logic
  def move_next(current_quiz=nil)

    session.send_typing_on

    respondent = find_or_initialize_respondent session
    if respondent.nil?
      if session.response_no?
        session.send_text session.bot.message_for(:greeting_msg)
        return
      else
        respondent = initial_respondent session
      end
    end

    if current_quiz.nil?
      current_quiz = respondent.question
      save_current_response(respondent, current_quiz, session.response_text)
    end

    next_quiz = next_question respondent, current_quiz
    session.send_question next_quiz

    finish(respondent) if last_question?(next_quiz)

    if blocked_question?(next_quiz)
      respondent.save_state next_quiz
      return
    end

    move_next(next_quiz)
  end

  protected

  def last_question? question
    question.nil?
  end

  def blocked_question? question
    return (last_question?(question) || question.required == true) ? true : false
  end

  def next_question(respondent, question = nil)
    next_quiz = session.bot.next_question_of(question)

    return next_question(respondent, next_quiz) if skip_question(respondent, next_quiz)

    next_quiz
  end

  def skip_question(respondent, question)
    return false if question.nil? || !question.has_relevants?

    expression = YAML.load question.relevants

    !Survey.matched?(respondent, expression)
  end

  def finish respondent
    session.terminate respondent
  end

  def save_current_response respondent, question, answer
    return if question.nil?

    respondent.surveys.create(question: question, value: answer)
  end

  def find_or_initialize_respondent session
    return initial_respondent session if session.get_started?

    respondent = Respondent.find_last(session)

    respondent = nil if respondent.completed?

    respondent
  end

  def initial_respondent session
    Respondent.instance_of(session)
  end

end
