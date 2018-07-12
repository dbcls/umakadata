class GithubIssue
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :description
  attr_reader :id


  def save(endpoint)
    if title.empty?
      errors.add(:base, 'Title cannot be blank')
      return
    end

    if GithubHelper.issue_exists?(title)
      errors.add(:base, "Issue #{title} already exists")
      return
    end

    begin
      remote_issue = GithubHelper.create_issue(title, description, labels: [endpoint.name, 'endpoints'])
      @id = remote_issue[:number]
    rescue Octokit::ClientError => e
      errors.add(:base, e.message)
    end
  end
end
