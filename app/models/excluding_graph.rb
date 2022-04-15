class ExcludingGraph < ApplicationRecord
  belongs_to :endpoint

  validates :uri, presence: true
end
