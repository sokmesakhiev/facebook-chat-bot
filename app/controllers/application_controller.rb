class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery except: %i[post_webhook get_webhook]

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
end
