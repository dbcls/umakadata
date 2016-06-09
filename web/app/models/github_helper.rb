require 'octokit'

class GithubHelper

  def initialize
    @client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
  end

  def create_issue(title)
    issues = @client.issues(Rails.application.secrets.github_repo)
    dose_not_exist_issue = issues.select {|issue| issue[:title] == title}.empty?
    @client.create_issue(Rails.application.secrets.github_repo, title) if dose_not_exist_issue
  end

  def edit_issue(number, title)
    @client.update_issue(Rails.application.secrets.github_repo, number, title)
  end

  def close_issue(number)
  end

end