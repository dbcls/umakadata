class ResourceURI < ApplicationRecord
  belongs_to :endpoint

  validate :both_uri_and_filter_cannot_be_specified

  private

  def both_uri_and_filter_cannot_be_specified
    if uri.present? && (allow.present? || deny.present?)
      errors.add(:base, 'Both URI and filters cannot be specified on a record.')
    end
  end
end
