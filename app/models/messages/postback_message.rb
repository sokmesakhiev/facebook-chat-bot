class Messages::PostbackMessage < Message
  def initialize options
    super(:postback, options)
  end

  def value
    @options['postback']['payload'] rescue nil
  end
end
