class Message
  def initialize type, options = {}
    @type = type
    @options = options
  end

  # user session id
  def user_session_id
    @options['sender']['id'] rescue nil
  end

  # page id
  def page_id
    @options['recipient']['id'] rescue nil
  end

  def timestamp
    @options['timestamp'] || Time.now.to_i
  end

  def type
    @type
  end

  # reply text/media message
  def value
    raise 'You have to override'
  end

end
