# frozen_string_literal: true

class SurveyService
  attr_accessor :user_session_id, :facebook_page_id

  def initialize(user_id, page_id)
    @user_session_id = user_id
    @facebook_page_id = page_id
    @question_user = QuestionUser.find_or_create_by(user_session_id: user_id)
    @bot = Bot.find_by(facebook_page_id: page_id)
    @bot_chat = BotChatService.new(@bot)
  end

  def first_question
    @bot_chat.first
  end

  def save_state(question)
    @question_user.update_attribute(:current_question_id, question['id'])
  end

  def save_response(response_message)
    UserResponse.create(user_session_id: user_session_id, question_id: @question_user.current_question_id, value: response_message)
  end

  def next_question
    @nex_question ||= next_q
  end

  def last_question?
    @question_user.current_question_id.present? && @bot_chat.last?(@question_user.current_question_id)
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

  def send_typing_on
    message_data = {
      'recipient' => {
        'id' => user_session_id
      },
      'sender_action' => 'typing_on'
    }

    send_api(message_data)
  end

  def send_text_message(message)
    message_data = {
      'recipient' => {
        'id' => user_session_id
      },
      'message' => {
        'text' => message,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      }
    }

    send_api(message_data)
  end

  def send_api(message_data = {})
    message_data['access_token'] = @bot.facebook_page_access_token

    request = Typhoeus::Request.new(
      'https://graph.facebook.com/v2.6/me/messages',
      method: :POST,
      body: 'this is a request body',
      params: message_data,
      headers: { Accept: 'application/json' }
    )

    request.run
    response = request.response
    if response.code == 200
      result = JSON.parse response.response_body
      recipient_id = result['recipient_id']
      message_id = result['message_id']
      if message_id
        puts "Successfully sent message with id #{message_id}to recipient #{recipient_id}"
      else
        puts "Successfully called Send API for recipient #{recipient_id}"
      end
    else
      puts "Failed calling Send API #{response.code}"
    end
  end

  private

  def next_q(question_id = nil)
    current = nil

    if question_id.present? || @question_user.current_question_id.present?
      current = @bot_chat.find_current_index(question_id || @question_user.current_question_id)
    end

    question = @bot_chat.next(current: current)

    return next_q(question.id) if question.present? && question.relevant.present? && skip_question(question)

    question
  end

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
      }
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
      }
    }
  end

  def select_multiple_template(question)
    select_one_template(question)
  end
end
