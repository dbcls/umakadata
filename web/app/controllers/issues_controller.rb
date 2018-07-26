class IssuesController < ApplicationController
  def form
    @issue = GithubIssue.new
    @endpoint = Endpoint.find(params[:endpoint_id])
  end

  def create
    @issue = GithubIssue.new(params[:github_issue])
    @endpoint = Endpoint.find(params[:endpoint_id])
    session[:issue_info] = {
        'title' => @issue.title,
        'description' => @issue.description,
        'endpoint_name' => @endpoint.name,
    }
    session[:prev_url] = request.referer
    redirect_to '/auth/github'
  end

  def after_authorization
    issue_info = session[:issue_info]
    return redirect_to root_path unless issue_info

    @issue = GithubIssue.new(description: issue_info['description'], title: issue_info['title'])
    @issue.save(issue_info['endpoint_name'], session[:oauth_token])
    prev_url = session[:prev_url] || root_url

    session.delete(:issue_info)
    session.delete(:oauth_token)

    if @issue.errors.any?
      redirect_to prev_url, flash: {failure: "Failure on Issue Creation: \n #{@issue.errors.full_messages.join("\n")}"}
    else
      redirect_to "https://github.com/#{Rails.application.secrets.github_repo}/issues/#{@issue.id}"
    end
  end
end