class Measurement < ApplicationRecord
  belongs_to :evaluation
  has_many :activities, dependent: :destroy

  attribute :exceptions, :binary_hash
end
