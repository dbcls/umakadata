require 'octokit'

class GithubHelper
  #
  # non-destructive API
  #

  # @return [Array<Sawyer::Resource>] A list of issues for a repository.
  def self.list_issues(options = {})
    call_github_api do |client, github_repo|
      client.auto_paginate = true
      client.list_issues(github_repo, **options)
    end
  end

  # @return [Array<Sawyer::Resource>] A list of the labels currently on the issue
  def self.labels_for_issue(number, options = {})
    call_github_api { |client, github_repo| client.labels_for_issue(github_repo, number, options) }
  end

  # @return [Sawyer::Resource] A single label from the repository
  def self.get_label(name)
    call_github_api { |client, github_repo| client.label(github_repo, name) }
  end

  # @return [Sawyer::Resource] An issue
  def self.find_issue_by_title(title)
    issues = call_github_api { |client, github_repo| client.issues(github_repo) }
    issues.find { |issue| issue[:title] == title }
  end

  # @return [TrueClass, FalseClass]
  def self.label_exists?(name)
    get_label(name).present?
  rescue Octokit::NotFound
    false
  end

  # @return [TrueClass, FalseClass]
  def self.issue_exists?(title)
    find_issue_by_title(title).present?
  rescue Octokit::NotFound
    false
  end

  #
  # destructive API
  #

  # @return [Sawyer::Resource] Your newly created issue
  def self.create_issue(title, body = nil, options = {})
    call_github_api { |client, github_repo| client.create_issue(github_repo, title, body, options) }
  end

  # @return [Sawyer::Resource] The updated Issue
  def self.update_issue(number, title)
    call_github_api { |client, github_repo| client.update_issue(github_repo, number, title) }
  end

  # Add label(s) to an Issue
  # No errors occur if label(s) already exist
  # @return [Array<Sawyer::Resource>] A list of the labels currently on the issue
  def self.add_labels_to_an_issue(number, labels)
    call_github_api { |client, github_repo| client.add_labels_to_an_issue(github_repo, number, labels) }
  end

  # @return [Sawyer::Resource] The updated Issue
  def self.close_issue(number)
    call_github_api { |client, github_repo| client.close_issue(github_repo, number) }
  end

  # @return [Sawyer::Resource] The new label
  def self.add_label(label, color)
    call_github_api { |client, github_repo| client.add_label(github_repo, label, color) }
  end

  # @return [Sawyer::Resource] The updated label
  def self.update_label(label, options)
    call_github_api { |client, github_repo| client.update_label(github_repo, label, options) }
  end

  # @return [TrueClass, FalseClass]
  def self.delete_label(label)
    call_github_api { |client, github_repo| client.delete_label!(github_repo, label) }
  end

  def self.call_github_api
    retry_count = 0

    begin
      yield client, Rails.application.credentials.github_repo
    rescue Octokit::ServiceUnavailable => e
      raise e if (retry_count += 1) > 3

      sleep(5 * 2 ** retry_count)
    end
  end

  def self.client
    Octokit::Client.new(connection_options: {
                          headers: {
                            'Authorization' => "token #{Rails.application.credentials.github_token}"
                          }
                        })
  end

  def self.available?
    Rails.application.credentials.github_token.present? && Rails.application.credentials.github_repo.present?
  end
end
