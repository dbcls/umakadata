class CrawlLog < ActiveRecord::Base
  has_many :evaluations

  def self.latest
    finished.last
  end

  def self.finished
    where.not(finished_at: nil)
  end

  def self.started_at(date)
    self.where(started_at: date.all_day).take
  end
end
