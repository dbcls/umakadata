require 'octokit'

class GithubHelper

  def self.create_issue(title)
    proc = Proc.new {|client, github_repo| client.issues(github_repo)}
    issues = call_github_api(proc)
    return if issues.nil?
    dose_not_exist_issue = issues.select {|issue| issue[:title] == title}.empty?
    if dose_not_exist_issue
      proc = Proc.new{|client, github_repo| client.create_issue(github_repo, title)}
      call_github_api(proc)
    end
  end

  def self.edit_issue(number, title)
    proc = Proc.new{|client, github_repo| client.update_issue(github_repo, number, title)}
    call_github_api(proc)
  end

  def self.close_issue(number)
    proc = Proc.new{|client, github_repo| client.close_issue(github_repo, number)}
    call_github_api(proc)
  end

  def self.list_issues
    proc = Proc.new{|client, github_repo|
      client.auto_paginate = true
      client.list_issues(github_repo, {:state => 'all'})
    }
    call_github_api(proc)
  end

  def self.call_github_api(proc)
    if Rails.application.secrets.github_token.blank? || Rails.application.secrets.github_repo.blank?
      p "Does not set github api configuration"
      return
    end

    begin
      client = Octokit::Client.new(:access_token => Rails.application.secrets.github_token)
      return proc.call(client, Rails.application.secrets.github_repo)
    rescue => e
      p e.message
    end
  end

end
