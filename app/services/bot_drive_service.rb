# frozen_string_literal: true

require "googleauth"

class BotDriveService
  attr_accessor :credentials

  def initialize
    set_credentials
  end

  def session(params)
    fetch_token(params)
    GoogleDrive::Session.from_credentials(credentials)
  end

  def fetch_token(params)
    if code = params[:code].presence
      credentials.code = code
    elsif token = params[:access_token].presence
      credentials.refresh_token = token
    end

    credentials.fetch_access_token!
  end

  def authorize_url
    credentials.authorization_uri.to_s
  end

  private

  def set_credentials
    @credentials ||= Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: [
        "https://www.googleapis.com/auth/drive",
        "https://spreadsheets.google.com/feeds/",
      ],
      redirect_uri: ENV['GOOGLE_CALLBACK_URL'])
  end
end
