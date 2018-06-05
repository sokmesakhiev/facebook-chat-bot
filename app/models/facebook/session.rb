class Facebook::Session
  attr_reader :user_session_id, :bot, :response_text
  
  def initialize user_session_id, page_id, response_text
    @user_session_id = user_session_id
    @bot = Bot.find_by(facebook_page_id: page_id)
    @response_text = response_text
  end
end
