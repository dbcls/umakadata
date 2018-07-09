class CrawlLog < ActiveRecord::Base
  has_many :evaluations

  def self.latest
    self.where.not(finished_at: nil).last
  end

  def self.started_at(date)
    self.where(started_at: date.all_day).take
  end
end
