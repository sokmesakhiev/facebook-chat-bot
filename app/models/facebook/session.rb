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

  def terminate respondent
    respondent.mark_as_completed!

    send_text bot.message_for(:completing_msg)

    send_aggregate_result respondent

    send_text bot.message_for(:restart_msg), restart_buttons
  end

  protected

  def send_aggregate_result respondent
    aggregation = bot.has_aggregate? ? bot.get_aggregation(Survey.score_of(respondent, bot.scorable_questionnaires)) : nil
    send_text aggregation.result if aggregation
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
