class Activity < ApplicationRecord
  belongs_to :measurement

  attribute :request, :binary_hash
  attribute :response, :binary_hash
  attribute :exceptions, :binary_hash
end
