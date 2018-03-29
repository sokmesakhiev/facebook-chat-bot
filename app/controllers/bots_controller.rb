class BotsController < ApplicationController
  def index
    @bots = policy_scope(Bot)
  end

  def new
    @bot = current_user.bots.new
    authorize @bot
  end

  def create
    @bot = current_user.bots.new(data_params)
    authorize @bot

    if @bot.save
      redirect_to bots_path
    else
      render :new
    end
  end

  def show
    @bot = current_user.bots.find(params[:id])
    authorize @bot
  end

  def edit
    @bot = current_user.bots.find(params[:id])
    authorize @bot
  end

  def update
    @bot = current_user.bots.find(params[:id])
    authorize @bot

    if @bot.update_attributes(data_params)
      redirect_to bots_path
    else
      render :edit
    end
  end

  def destroy
    @bot = current_user.bots.find(params[:id])
    authorize @bot
    @bot.destroy

    redirect_to bots_path
  end

  private

  def data_params
    params.permit(:name, :facebook_page_id, :facebook_page_access_token)
  end
end
