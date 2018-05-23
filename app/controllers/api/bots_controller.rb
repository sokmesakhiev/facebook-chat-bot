module Api
  class BotsController < ApplicationController
    def update
      @bot = Bot.find(params[:id])

      if @bot.update_attributes(data_params)
        render json: @bot, status: :ok
      else
        render json: @bot.errors.full_messages, status: :unprocessable_entity
      end
    end

    private

    def data_params
      params.permit(:google_access_token, :google_spreadsheet_key, :google_spreadsheet_title)
    end
  end
end
