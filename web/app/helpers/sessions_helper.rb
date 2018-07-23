module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    true if session[:oauth_token]
  end

  def username
    return unless session[:username]
    session[:username]
  end

  def oauth_token
    return unless session[:oauth_token]
    session[:oauth_token]
  end
end
