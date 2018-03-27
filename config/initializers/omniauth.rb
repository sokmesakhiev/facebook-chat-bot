OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, FACEBOOK::CONFIG["appId"], FACEBOOK::CONFIG["appSecret"]
end
