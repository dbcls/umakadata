class GithubIssue
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :description
  attr_reader :id


  def save(endpoint_name, oauth_token)
    if title.empty?
      errors.add(:base, 'Title cannot be blank')
      return
    end

    unless oauth_token
      errors.add(:base, 'authorize error')
      return
    end

    if GithubHelper.issue_exists?(title)
      errors.add(:base, "Issue #{title} already exists")
      return
    end

    begin
      client = Octokit::Client.new(:access_token => oauth_token)
      remote_issue = client.create_issue(Rails.application.secrets.github_repo, title, description )
      @id = remote_issue[:number]
      GithubHelper.add_labels_to_an_issue(@id, [endpoint_name, 'endpoints']) # Only admin can add labels
    rescue Octokit::ClientError => e
      errors.add(:base, e.message)
    end
  end
end
