class Facebook::Client
  def self.send_api params
    request = Typhoeus::Request.new(
      'https://graph.facebook.com/v2.6/me/messages',
      method: :POST,
      body: 'this is a request body',
      params: params,
      headers: { Accept: 'application/json' }
    )

    request.run
  end
end
