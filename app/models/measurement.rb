class Measurement < ApplicationRecord
  belongs_to :evaluation
  has_many :activities
end
