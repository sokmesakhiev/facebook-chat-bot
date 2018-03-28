module Bots
  class SurveysController < ApplicationController
    def index
      @bot = Bot.find(params[:bot_id])
      @questions = @bot.questions
    end

    def import
      @bot = Bot.find(params[:bot_id])
      @bot.import(params[:file])

      redirect_to bot_surveys_path(@bot), notice: 'Form imported.'
    end

    def destroy
      @bot = Bot.find(params[:bot_id])
      @bot.questions.destroy_all

      redirect_to bot_surveys_path(@bot)
    end
  end
end
