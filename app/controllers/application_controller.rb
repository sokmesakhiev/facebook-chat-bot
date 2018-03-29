class ApplicationController < ActionController::Base
  include Pundit
  # after_action :verify_authorized
  # after_action :verify_policy_scoped, only: :index

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery except: %i[post_webhook get_webhook], prepend: true
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def set_constance
    # @bodyParser = require('body-parser'),
    #               @config = require('config'),
    #               @crypto = require('crypto'),
    #               @express = require('express'),
    #               @https = require('https'),
    #               @request = require('request')

    # unless FACEBOOK::CONFIG['appSecret'] && FACEBOOK::CONFIG['accessToken'] && FACEBOOK::CONFIG['validationToken']
    #   puts 'Missing config values'
    #   head :forbidden
    # end
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
