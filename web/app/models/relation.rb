require 'csv'
require 'nkf'

class Relation < ActiveRecord::Base

  belongs_to :endpoint
  validates :endpoint_id, presence: true
  validates :endpoint_id, numericality: { only_integer: true }
  validates :dst_id, presence: true
  validates :dst_id, numericality: { only_integer: true }
  validates :name, presence: true

  def self.import_csv(file_path)
    CSV.foreach(file_path, {headers: true}) do |row|
      relation = Relation.new
      relation.endpoint_id = row[0]
      relation.dst_id = row[1]
      relation.name = NKF::nkf("-w", row[2].to_s)
      relation.save!
    end
  end


end
