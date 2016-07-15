require "csv"
require "nkf"
require 'uri'

class Prefix < ActiveRecord::Base

  belongs_to :endpoint
  validates :uri, format: URI::regexp
  validates :element_type, presence: true

  def self.import_csv(params)
    CSV.parse(params[:endpoint][:file].read, {headers: true}).each do |row|
      prefix = Prefix.new
      prefix.endpoint_id = params[:id]
      prefix.uri = NKF::nkf("-w", row[0].to_s)
      prefix.element_type = params[:endpoint][:element_type]
      prefix.save!
    end
  end

  def self.validates_params(params)
    if params[:endpoint].nil?
      return 'element_type and CSV file are required'
    end
    if params[:endpoint][:element_type].nil?
      return 'element_type required'
    end
    if params[:endpoint][:file].nil?
      return 'CSV file required'
    end
    CSV.parse(params[:endpoint][:file].read, {headers: true}).each do |row|
      unless NKF::nkf("-w", row[0].to_s) =~ URI::regexp(%w(http https))
        return 'CSV file contains invalid URI'
      end
    end
    nil
  end

end
