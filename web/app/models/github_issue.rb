class GithubIssue
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :description

  validates :title , presence: true

  def create(endpoint)
    raise("issue '#{title}' already exists") if GithubHelper.issue_exists?(title)
    GithubHelper.create_issue(title, description, labels: [endpoint.name, 'endpoints'])
  end
end
