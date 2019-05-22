class Facebook::Session
  attr_reader :user_session_id, :bot, :response_text

  def initialize user_session_id, page_id, response_text = nil
    @user_session_id = user_session_id
    @bot = Bot.find_by(facebook_page_id: page_id)
    @response_text = response_text
  end

  def get_started?
    response_text == Question::QUESTION_GET_STARTED
  end

  def response_no?
    response_text == 'no'
  end

  def send_typing_on
    params = request_params('sender_action' => 'typing_on')
    Facebook::Client.send_api(params)
  end

  def send_text text, buttons = []
    message_params = if buttons.empty?
      {
        'message' => {
          'text' => text,
          'metadata' => 'DEVELOPER_DEFINED_METADATA'
        }
      }
    else
      {
        'message' => {
          'attachment' => {
            'type' => 'template',
            'payload' => {
              'template_type' => 'button',
              'text' => text,
              'buttons' => buttons.take(3)
            }
          }
        }
      }
    end

    params = request_params(message_params)

    Facebook::Client.send_api(params)
  end

  def send_question question
    return if question.nil?

    params = request_params(question.to_fb_params)
    Facebook::Client.send_api(params)
  end


  def send_question question
    return if question.nil?

    params = request_params(question.to_fb_params)
    Facebook::Client.send_api(params)
  end

  def terminate respondent
    respondent.mark_as_completed!

    send_aggregate_result

    send_restart_message
  end

  def send_greeting_message
    send_text bot.greeting_msg || Bot::DEFAULT_GREETING_MSG
  end

  protected

  def send_aggregate_result msg = 'Thank you!'
    aggregation = bot.has_aggregate? ? bot.get_aggregation(Survey.score_of(respondent, bot.scorable_questionnaires)) : nil
    msg = aggregation.result if aggregation

    send_text msg
  end

  def send_restart_message
    restart_msg = bot.restart_msg || Bot::DEFAULT_RESTART_MSG
    send_text restart_msg, restart_buttons
  end

  def request_params options = {}
    options.merge(
      'access_token' => bot.facebook_page_access_token,
      'recipient' => {
        'id' => user_session_id
      }
    )
  end

  def restart_buttons
    [
      {
        'type' => 'postback',
        'title' => 'Yes',
        'payload' => 'yes'
      },
      {
        'type' => 'postback',
        'title' => 'No',
        'payload' => 'no'
      }
    ]
  end
end
