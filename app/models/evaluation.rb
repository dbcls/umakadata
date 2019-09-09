class Evaluation < ApplicationRecord
  belongs_to :crawl
  belongs_to :endpoint
  has_many :measurements, dependent: :destroy

  attribute :exceptions, :binary_hash

  before_save :evaluate_measurements

  def evaluate_measurements
    return unless measurements.any? { |x| x.new_record? || x.changed? }
    # TODO: IMPLEMENT ME!
  end
end
