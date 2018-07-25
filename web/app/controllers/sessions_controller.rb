class SessionsController < ApplicationController
  def callback
    auth                         = request.env['omniauth.auth']
    session[:oauth_token]        = auth.credentials.token

    redirect_to issues_after_authorization_path
  end

  def failure
    redirect_to session[:prev_url] || root_path
  end
end
