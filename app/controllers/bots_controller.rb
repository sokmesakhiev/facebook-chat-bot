class BotsController < ApplicationController
  def index
    @bots = Bot.all.includes(:questions)
  end

  def new
    @bot = Bot.new
  end

  def create
    @bot = Bot.new(name: params[:name])
    if @bot.save
      redirect_to bots_path
    else
      render :new
    end
  end

  def show
    @bot = Bot.find(params[:id])
  end

  def edit
    @bot = Bot.find(params[:id])
  end

  def update
    @bot = Bot.find(params[:id])
    if @bot.update_attributes(name: params[:name])
      redirect_to bots_path
    else
      render :edit
    end
  end

  def destroy
    @bot = Bot.find(params[:id])
    @bot.destroy

    redirect_to bots_path
  end
end
