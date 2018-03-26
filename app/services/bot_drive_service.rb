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
    credentials.authorization_uri.to_s + '&prompt=consent'
  end

  private

  def session
    @session ||= GoogleDrive::Session.from_access_token(access_token)
  end

  def access_token
    # https://stackoverflow.com/questions/10827920/not-receiving-google-oauth-refresh-token
    # https://github.com/instedd/hub/blob/master/app/models/google_spreadsheets_connector.rb#L50
    if access_token_expired?
      credentials.refresh_token = bot.google_refresh_token
      res = credentials.fetch_access_token!
      bot.google_access_token = res['access_token']
      bot.google_token_expires_at = res['expires_in'].seconds.from_now
      bot.google_refresh_token = res['refresh_token'] if res['refresh_token'].present?
      bot.save
    end

    bot.google_access_token
  end

  def access_token_expired?
    if bot.google_token_expires_at
      Time.now > bot.google_token_expires_at - 1.minute
    else
      false
    end
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
  end
end
