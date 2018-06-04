class Messages::TextMessage < Message
  def initialize options
    super(:text, options)
  end

  def value
    @options['message']['text'] rescue nil
  end
end
