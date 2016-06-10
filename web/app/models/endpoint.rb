class Endpoint < ActiveRecord::Base
  has_many :evaluations
  has_one :evaluation

  after_create do
    issue = GithubHelper.create_issue(self.name)
    self.update_column(:issue_id, issue[:number]) unless issue.nil?
  end

  after_update do
    GithubHelper.edit_issue(self.issue_id, self.name)
  end

  after_destroy do
    GithubHelper.close_issue(self.issue_id)
  end

end
