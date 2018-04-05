# frozen_string_literal: true

class MessageService
  attr_accessor :user_session_id, :facebook_page_id, :message, :bot

  def initialize(user_id, page_id, text_message)
    @user_session_id = user_id
    @facebook_page_id = page_id
    @message = text_message
    @bot = Bot.find_by(facebook_page_id: page_id)
  end

  def response_message
    return if message.blank? || bot.nil? || !bot.published?

    survey = SurveyService.new(user_session_id, facebook_page_id)
    survey.send_typing_on
    handle_response(survey)
  end

  def response_postback
    return if bot.nil? || !bot.published?

    survey = SurveyService.new(user_session_id, facebook_page_id)
    survey.send_typing_on

    if message == 'first_welcome'
      survey.save_state(survey.first_question)
      return survey.send_api(survey.template_message(survey.first_question))
    end

    handle_response(survey)
  end

  private

  def handle_response(survey)
    survey.save_response(message)

    if survey.last_question? || survey.next_question.nil?
      return survey.send_text_message('Thank you!')
    end

    survey.save_state(survey.next_question)
    survey.send_api(survey.template_message(survey.next_question))
  end
end
