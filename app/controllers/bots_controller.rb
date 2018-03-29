class BotsController < ApplicationController
  def index
    @bots = policy_scope(Bot)
  end

  def new
    @bot = Bot.new

    authorize @bot
  end

  def create
    @bot = Bot.new(name: params[:name])

    authorize @bot

    if @bot.save
      redirect_to bots_path
    else
      render :new
    end
  end

  def show
    @bot = Bot.find(params[:id])

    authorize @bot
  end

  def edit
    @bot = Bot.find(params[:id])

    authorize @bot
  end

  def update
    @bot = Bot.find(params[:id])

    authorize @bot

    if @bot.update_attributes(name: params[:name])
      redirect_to bots_path
    else
      render :edit
    end
  end

  def destroy
    @bot = Bot.find(params[:id])

    authorize @bot

    @bot.destroy

    redirect_to bots_path
  end
end
