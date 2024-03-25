class Graph < ApplicationRecord
  belongs_to :endpoint

  enum mode: { exclude: 0, include: 1 }

  validates :endpoint_id, uniqueness: true
  validates :mode, presence: true
  validates :graphs, presence: true

  before_save do |graph|
    graph.graphs = self[:graphs].split(/\R/).map(&:strip).reject(&:blank?).join("\n")
  end

  def graph_list
    self[:graphs]&.split("\n")
  end
end
