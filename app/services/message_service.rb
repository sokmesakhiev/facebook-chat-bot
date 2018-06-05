# frozen_string_literal: true

class MessageService
  # TODO refactoring text parameter to message object
  def receive fb_message_session
    return if fb_message_session.bot.nil? || !fb_message_session.bot.published?

    survey = SurveyService.new(fb_message_session)
    survey.send_typing_on

    return survey.start if fb_message_session.text == Question::QUESTION_FIRST_WELCOME

    survey.move_next
  end
end
