class Endpoint < ApplicationRecord
  has_many :evaluations

  def latest_alive_evaluation
    evaluations.where(alive: true).order(created_at: :desc).limit(1).first
  end
end
