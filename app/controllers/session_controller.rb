class SessionController < ApplicationController
  # GET /auth/:provider/callback
  def callback
    auth = request.env['omniauth.auth']
    session[:oauth_token] = auth.credentials.token

    redirect_to auth_after_authorization_path
  end

  # GET /auth/after_authorization
  def after_authorization
    unless (issue_info = session[:issue_info])
      redirect_to root_path
      return
    end

    @issue = GithubIssue.new(description: issue_info['description'], title: issue_info['title'])
    @issue.save(issue_info['endpoint_name'], session[:oauth_token])
    prev_url = session[:prev_url] || root_url

    session.delete(:issue_info)
    session.delete(:oauth_token)

    if @issue.errors.any?
      redirect_to prev_url, flash: {failure: "Failure on Issue Creation: \n #{@issue.errors.full_messages.join("\n")}"}
    else
      redirect_to "https://github.com/#{Rails.application.credentials.github_repo}/issues/#{@issue.id}"
    end
  end

  # GET /auth/failure
  def failure
    redirect_to session[:prev_url] || root_path
  end
end
