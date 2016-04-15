class Endpoint < ActiveRecord::Base
  has_many :evaluations
  has_one :evaluation
end
