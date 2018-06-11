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

  def send_text text
    params = request_params(
      'message' => {
        'text' => text,
        'metadata' => 'DEVELOPER_DEFINED_METADATA'
      }
    )
    Facebook::Client.send_api(params)
  end

  def send_question question
    return if question.nil?

    params = request_params(question.to_fb_params)
    Facebook::Client.send_api(params)
  end

  def terminate
    reply_msg = 'Thank you!'
    if bot.has_aggregate?
      aggregation = bot.get_aggregation(bot.scoring_of(user_session_id))
      
      reply_msg = aggregation.result if aggregation
    end

    # TODO refactoring
    # clear state in question_user
    QuestionUser.find_or_create_by(user_session_id: user_session_id, bot_id: bot.id).destroy

    send_text(reply_msg)
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
end
