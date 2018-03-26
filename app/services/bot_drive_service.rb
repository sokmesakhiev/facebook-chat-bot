# frozen_string_literal: true

require 'googleauth'

class BotDriveService
  attr_accessor :credentials, :bot

  def initialize(bot)
    @bot = bot
    set_credentials
  end

  def worksheets
    session.spreadsheet_by_key(bot.google_spreadsheet_key).worksheets
  end

  def authorize_url
    credentials.authorization_uri.to_s
  end

  private

  def session
    @session ||= GoogleDrive::Session.from_credentials(credentials)
  end

  def fetch_token
    credentials.refresh_token = bot.google_access_token
    res = credentials.fetch_access_token!
    bot.update_attribute(:google_access_token, res['access_token'])
  end

  def set_credentials
    @credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: [
        'https://www.googleapis.com/auth/drive',
        'https://spreadsheets.google.com/feeds/'
      ],
      redirect_uri: ENV['GOOGLE_CALLBACK_URL']
    )

    fetch_token
    session
  end
end
