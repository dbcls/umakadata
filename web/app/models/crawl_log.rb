class CrawlLog < ActiveRecord::Base
  has_many :evaluations
  scope :latest, -> { where.not(finished_at: nil).last }

  def self.started_at(date)
    self.where(started_at: date.all_day).take
  end
end
