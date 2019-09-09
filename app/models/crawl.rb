class Crawl < ApplicationRecord
  has_many :evaluations, dependent: :destroy
end
