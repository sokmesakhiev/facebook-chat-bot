class BotsController < ApplicationController
  def index
    @bots = policy_scope(Bot)
  end

  def create
    @bot = current_user.bots.new(data_params)
    authorize @bot

    if @bot.save
      redirect_to bot_path(@bot), notice: 'Bot created successfully!'
    else
      redirect_to bots_path, alert: @bot.errors.full_messages
    end
  end

  def show
    @bot = Bot.find(params[:id])
    authorize @bot
  end

  def update
    @bot = Bot.find(params[:id])
    authorize @bot

    if @bot.update_attributes(data_params)
      ::Bots::GetStartWorker.perform_async(@bot.id)

      redirect_to bot_path(@bot), notice: 'Bot updated successfully!'
    else
      redirect_to bot_path(@bot), alert: @bot.errors.full_messages
    end
  end

  def destroy
    @bot = Bot.find(params[:id])
    authorize @bot

    if @bot.destroy
      redirect_to bots_path(@bot), notice: 'Bot deleted successfully!'
    else
      redirect_to bots_path(@bot), alert: @bot.errors.full_messages
    end

  end

  def import
    @bot = Bot.find(params[:id])
    @bot.import(params[:file])

    redirect_to bot_path(@bot), notice: 'Form imported successfully!'
  end

  def delete_survey
    @bot = Bot.find(params[:id])
    @bot.questions.destroy_all

    redirect_to bot_path(@bot), notice: 'Survey deleted successfully!'
  end

  private

  def data_params
    params.require(:bot).permit(:name, :facebook_page_id, :facebook_page_access_token)
  end
end
