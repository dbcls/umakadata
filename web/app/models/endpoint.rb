class Endpoint < ActiveRecord::Base
  has_many :evaluations
  has_one :evaluation

  after_create do
    ghelper = GithubHelper.new
    issue = ghelper.create_issue(self.name)
    self.update_column(:issue_id, issue[:number]) unless issue.nil?
  end

  after_update do
  end

  after_destroy do
  end

end
