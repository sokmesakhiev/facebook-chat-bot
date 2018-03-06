class HomeController < ApplicationController
  def index
    @bot_drive = BotDriveService.new
  end
end
