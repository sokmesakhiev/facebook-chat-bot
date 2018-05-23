require 'googleauth'

class OauthCallbacksController < ApplicationController
  def create
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: [
        'https://www.googleapis.com/auth/drive',
        'https://spreadsheets.google.com/feeds/'
      ],
      redirect_uri: ENV['GOOGLE_CLIENT_ORIGIN']
    )

    credentials.code = params[:code]
    res = credentials.fetch_access_token!

    bot = Bot.find(params[:bot_id])
    bot.google_access_token = res['access_token']
    bot.google_token_expires_at = res['expires_in'].seconds.from_now
    bot.google_refresh_token = res['refresh_token'] if res['refresh_token'].present?
    bot.save

    render json: res, status: :ok
  end
end
