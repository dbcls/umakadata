class SessionsController < ApplicationController
  def callback
    auth                         = request.env['omniauth.auth']
    session[:oauth_token]        = auth.credentials.token
    session[:oauth_token_secret] = auth.credentials.secret
    session[:username]           = auth["info"]["nickname"]
    session[:code]               = request.env['rack.request.query_hash']['code']

    redirect_to root_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
