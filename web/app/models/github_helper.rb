require 'octokit'

class GithubHelper

  def initialize
    @client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
  end

  def create_issue
  end

  def edit_issue(number)
  end

  def close_issue(number)
  end
end