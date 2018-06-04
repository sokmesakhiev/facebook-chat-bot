class Messages::MediaMessage < Message
  def initialize options
    super(:media, options)
  end

  def value
    @options['message']['attachments'].first['payload']['url'] rescue nil
  end
end
