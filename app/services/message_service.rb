# frozen_string_literal: true

class MessageService
  attr_accessor :user_session_id, :facebook_page_id, :bot

  # TODO refactoring text parameter to message object
  def initialize(user_id, page_id)
    @user_session_id = user_id
    @facebook_page_id = page_id
    @bot = Bot.find_by(facebook_page_id: page_id)
  end

  # TODO refactoring text parameter to message object
  def receive text
    return if bot.nil? || !bot.published?

    ChatbotService.send_typing_on(user_session_id, facebook_page_id)

    survey = SurveyService.new(user_session_id, facebook_page_id)

    if text == Question::QUESTION_FIRST_WELCOME
      survey.save_state(survey.first_question)
      return ChatbotService.send_question(user_session_id, facebook_page_id, survey.first_question)
    end

    survey.save_response(text)
    handle_response(survey)
  end

  private

  def handle_response(survey)
    if survey.last_question? || survey.next_question.nil?
      return ChatbotService.send_text(user_session_id, facebook_page_id, 'Thank you!')
    end

    survey.save_state(survey.next_question)
    ChatbotService.send_question(user_session_id, facebook_page_id, survey.next_question)
  end
end
