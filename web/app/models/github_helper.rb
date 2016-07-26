require 'octokit'

class GithubHelper

  def self.create_issue(title)
    issues = call_github_api {|client, github_repo| client.issues(github_repo)}
    return if issues.nil?
    does_not_exist_issue = issues.select {|issue| issue[:title] == title}.empty?
    if does_not_exist_issue
      call_github_api {|client, github_repo| client.create_issue(github_repo, title)}
    end
  end

  def self.edit_issue(number, title)
    call_github_api {|client, github_repo| client.update_issue(github_repo, number, title)}
  end

  def self.close_issue(number)
    call_github_api {|client, github_repo| client.close_issue(github_repo, number)}
  end

  def self.list_issues
    call_github_api do |client, github_repo|
      client.auto_paginate = true
      client.list_issues(github_repo, {:state => 'all'})
    end
  end

  def self.call_github_api
    if Rails.application.secrets.github_token.blank? || Rails.application.secrets.github_repo.blank?
      p "Does not set github api configuration"
      return
    end

    begin
      client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
      yield(client, Rails.application.secrets.github_repo)
    rescue => e
      p e.message
    end
  end

end
