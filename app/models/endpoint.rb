class Endpoint < ApplicationRecord
  has_many :evaluations
  has_many :excluding_graphs
  has_many :resource_uris, class_name: ResourceURI.name
  has_many :vocabulary_prefixes

  def latest_alive_evaluation
    evaluations.where(alive: true).order(created_at: :desc).limit(1).first
  end
end
