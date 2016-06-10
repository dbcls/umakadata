require 'octokit'

class GithubHelper

  def self.create_issue(title)
    client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
    issues = client.issues(Rails.application.secrets.github_repo)
    dose_not_exist_issue = issues.select {|issue| issue[:title] == title}.empty?
    client.create_issue(Rails.application.secrets.github_repo, title) if dose_not_exist_issue
  end

  def self.edit_issue(number, title)
    client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
    client.update_issue(Rails.application.secrets.github_repo, number, title)
  end

  def self.close_issue(number)
    client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
    client.close_issue(Rails.application.secrets.github_repo, number)
  end

end