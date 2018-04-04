# frozen_string_literal: true

class SurveyService
  attr_accessor :user_session_id, :facebook_page_id, :bot

  def initialize(user_id, page_id)
    @user_session_id = user_id
    @facebook_page_id = page_id
    @question_user = QuestionUser.find_or_create_by(user_session_id: user_id)
    @bot = Bot.find_by(facebook_page_id: page_id)

    return if @bot.nil? || !bot.published?

    @bot_service = BotChatService.new(@bot)
  end

  def first_question
    @bot_service.first
  end

  def update_state(question)
    @question_user.update_attribute(:current_question_id, question['id'])
  end

  def update_response(response_message)
    UserResponse.create(user_session_id: user_session_id, question_id: current_question_id, value: response_message)
  end

  def next_question(question_id = nil)
    @nex_question ||= nextQ(question_id)
  end

  def nextQ(question_id)
    current = nil
    current = @bot_service.find_current_index(question_id || @question_user.current_question_id) if question_id.present? || @question_user.current_question_id.present?
    question = @bot_service.next(current: current)

    return nextQ(question.id) if question.present? && question.relevant.present? && skip_question(question)

    question
  end

  def current_question_id
    @question_user.current_question_id
  end

  def last_question?
    @question_user.current_question_id.present? && @bot_service.last?(@question_user.current_question_id)
  end

  def template_message(question)
    case question.question_type.strip.downcase
    when 'select_one'
      select_one_template(question)
    when 'select_multiple'
      select_multiple_template(question)
    else
      text_template(question)
    end
  end

  private

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

  def text_template(question)
    {
      'recipient' => {
        'id' => user_session_id
      },
      'message' => {
        'text' => question.label,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      },
      'access_token' => @bot.facebook_page_access_token
    }
  end

  def select_one_template(question)
    buttons = question.choices.map do |choice|
      {
        'type' => 'postback',
        'title' => choice.label,
        'payload' => choice.name
      }
    end

    {
      'recipient' => {
        'id' => user_session_id
      },
      'message' => {
        'attachment' => {
          'type' => 'template',
          'payload' => {
            'template_type' => 'button',
            'text' => question.label,
            'buttons' => buttons.take(3)
          }
        }
      },
      'access_token' => @bot.facebook_page_access_token
    }
  end

  def select_multiple_template(question)
    select_one_template(question)
  end
end
