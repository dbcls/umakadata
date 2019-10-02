class Activity < ApplicationRecord
  belongs_to :measurement

  attribute :request, :binary_hash
  attribute :response, :binary_hash
  attribute :trace, :json_array
  attribute :warnings, :json_array
  attribute :exceptions, :binary_hash
end
