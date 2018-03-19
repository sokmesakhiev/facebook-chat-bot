# frozen_string_literal: true

class SurveyService
  attr_accessor :user_session_id, :facebook_page_id

  def initialize(user_id, page_id)
    @user_session_id = user_id
    @facebook_page_id = page_id
    @question_user = QuestionUser.find_or_create_by(user_session_id: user_id)

    bot = Bot.find_by(facebook_page_id: page_id)
    @bot_service = BotChatService.new(bot)
  end

  def first_question
    question = @bot_service.first
    @question_user.update_attribute(:current_question_id, question.id)

    template_message(question)
  end

  def next_question
    current = nil
    current = @bot_service.find_current_index(@question_user.current_question_id) if @question_user.current_question_id.present?
    question = @bot_service.next(current: current)
    @question_user.update_attribute(:current_question_id, question.id)

    template_message(question)
  end

  def current_question_id
    @question_user.current_question_id
  end

  def last_question?
    @question_user.current_question_id.present? && @bot_service.is_last(@question_user.current_question_id)
  end

  private

  def template_message(question)
    case question.question_type.strip.downcase
    when 'select_one'
      select_one_template(question)
    when 'select_many'
      select_many_template(question)
    else
      text_template(question)
    end
  end

  def text_template(question)
    {
      "recipient" => {
        "id" => user_session_id
      },
      "message" => {
        "text" => question.label,
        "metadata" => "DEVELOPER_DEFINED_METADATA"
      }
    }
  end

  def select_one_template(question)
    buttons = question.choices.map do |choice|
      {
        "type" => "postback",
        "title" => choice.label,
        "payload" => choice.name
      }
    end

    {
      "recipient" => {
        "id" => user_session_id
      },
      "message" => {
        "attachment" => {
          "type" => "template",
          "payload" => {
            "template_type" => "button",
            "text" => question.label,
            "buttons" => buttons.take(3)
          }
        }
      }
    }
  end

  def select_many_template(question)
    select_one_template(question)
  end
end
