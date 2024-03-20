class Activity < ApplicationRecord
  include TruncateBytes

  belongs_to :measurement

  attribute :request, :binary_hash
  attribute :response, :binary_hash
  attribute :trace, :json_array
  attribute :warnings, :json_array
  attribute :exceptions, :binary_hash

  RESPONSE_MAX_BYTES = 10 * 1024

  def truncated_response
    if (body = response[:body]).present?
      response.merge(body: truncate_bytes(body, RESPONSE_MAX_BYTES, omission: "…\n[Trailing bodies are truncated]"))
    else
      response
    end
  end
end
