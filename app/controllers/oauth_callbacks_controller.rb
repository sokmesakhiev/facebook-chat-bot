require "googleauth"

class OauthCallbacksController < ApplicationController
  def create
    credentials = Google::Auth::UserRefreshCredentials.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      scope: [
        "https://www.googleapis.com/auth/drive",
        "https://spreadsheets.google.com/feeds/",
      ],
      redirect_uri: ENV['GOOGLE_CALLBACK_URL'])

    credentials.code = params[:code]
    resp = credentials.fetch_access_token!

    # @Todo: save access_token to database
    render json: resp, status: :ok
  end
end
