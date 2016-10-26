class CrawlLog < ActiveRecord::Base
  has_many :evaluations
  scope :latest, -> { where.not(finished_at: nil).last }
  scope :started_at, ->(date) { where(started_at: date.all_day).take }
end
