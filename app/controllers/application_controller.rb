class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery except: %i[post_webhook get_webhook]
  helper_method :current_user

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
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
