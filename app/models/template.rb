class Template
  attr_reader :user_session_id

  def initialize user_session_id = nil
    @user_session_id = user_session_id
  end

  def get(question)
    raise 'You have to override'
  end
end
