class FacebookPagesController < ApplicationController
  def index
    @pages = current_user.fb_graph.get_connections('me', 'accounts')

    render json: @pages, status: :ok
  end
end
