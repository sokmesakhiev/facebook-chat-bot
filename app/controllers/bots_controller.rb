class BotsController < ApplicationController
  before_filter :load_bot, only: [:show, :download]
  before_filter :csv_settings, only: [:download]

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
    authorize @bot

    @respondents = Respondent.where(bot: @bot).includes(:surveys).order(created_at: :desc).page(page).per(per_page)
  end

  def update
    @bot = Bot.find(params[:id])
    authorize @bot

    if @bot.update_attributes(facebook_params)
      ::Bots::GetStartWorker.perform_async(@bot.id)

      redirect_to bot_path(@bot), notice: 'Bot updated successfully!'
    else
      redirect_to bot_path(@bot), alert: @bot.errors.full_messages
    end
  end

  def activate
    @bot = Bot.find(params[:id])
    authorize @bot, :update?

    if @bot.update_attributes(published: true)
      redirect_to bots_path, notice: 'Bot activated successfully!'
    else
      redirect_to bots_path, alert: @bot.errors.full_messages
    end
  end

  def deactivate
    @bot = Bot.find(params[:id])
    authorize @bot, :update?

    if @bot.update_attributes(published: false)
      redirect_to bots_path, notice: 'Bot deactivated successfully!'
    else
      redirect_to bots_path, alert: @bot.errors.full_messages
    end
  end

  def import
    @bot = Bot.find(params[:id])
    authorize @bot, :update?

    @bot.import(params[:file])

    redirect_to bot_path(@bot), notice: 'Form imported successfully!'
  end

  def delete_survey
    @bot = Bot.find(params[:id])
    authorize @bot, :destroy?

    @bot.questions.destroy_all

    redirect_to bot_path(@bot), notice: 'Survey deleted successfully!'
  end

  # GET /bots/:bot_id/download.csv
  def download
    authorize @bot, :update?

    @respondents = Respondent.where(bot: @bot).includes(:surveys).order(created_at: :desc)
  end

  private

  def load_bot
    @bot = Bot.includes(:questions => [:choices]).find(params[:id])
  end

  def data_params
    params.require(:bot).permit(:name, :restart_msg, :greeting_msg, :facebook_page_id, :facebook_page_access_token)
  end

  def facebook_params
    param = params.require(:bot).permit(:facebook_page_id)
    param[:facebook_page_access_token] = current_user.fb_graph.get_page_access_token(param[:facebook_page_id])
    param
  end

  def page
    params[:page] || 1
  end

  def per_page
    params[:limit] || 10
  end

  def csv_settings
    @filename = "#{@bot.name}-#{Time.now.to_s.gsub(' ', '_')}).csv"
    @output_encoding = 'UTF-8'
    @streaming = true
    @csv_options = { :col_sep => ',' }
  end

end
