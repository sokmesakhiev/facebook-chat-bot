class BotsController < ApplicationController
  def index
  end

  def show
    @bot = Bot.first
  end

  def import
    @bot = Bot.first
    @bot.import(params[:file])

    redirect_to bots_path, notice: 'Form imported.'
  end
end
