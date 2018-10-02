class Facebook::Session
  attr_reader :user_session_id, :bot, :response_text
  
  def initialize user_session_id, page_id, response_text = nil
    @user_session_id = user_session_id
    @bot = Bot.find_by(facebook_page_id: page_id)
    @response_text = response_text
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
    reply_msg = 'Thank you!'
    if bot.has_aggregate?
      aggregation = bot.get_aggregation(Survey.score_of(respondent, bot.scorable_questionnaires))
      
      reply_msg = aggregation.result if aggregation
    end

    respondent.state = Respondent::STATE_COMPLETED
    respondent.save

    send_text(reply_msg)

    restart_msg = bot.restart_msg || Bot::DEFAULT_RESTART_MSG
    send_text(restart_msg, restart_buttons)
  end

  protected

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
      }
    ]
  end
end
