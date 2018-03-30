module Auth
  class CallbacksController < ActionController::Base
    def facebook
      user = User.from_omniauth(omniauth_params)

      if user.present?
        sign_in_and_redirect user, event: :authentication
      else
        redirect_to new_user_session_path, alert: "Your account doesn't exist!"
      end
    end

    def failure
      redirect_to :root
    end

    private

    def omniauth_params
      request.env['omniauth.auth']
    end
  end
end
