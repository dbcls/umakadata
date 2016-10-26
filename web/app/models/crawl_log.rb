class CrawlLog < ActiveRecord::Base
    has_many :evaluations
end
