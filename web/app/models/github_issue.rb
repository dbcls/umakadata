class GithubIssue
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :description
  attr_reader :id

  define_model_callbacks :save

  before_save {
    self.valid?
  }

  validates :title , presence: true

  def save(endpoint)
    if GithubHelper.issue_exists?(title)
      errors.add(:base, "issue '#{title}'already exists")
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
