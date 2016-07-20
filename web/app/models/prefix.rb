require "csv"
require "nkf"
require 'uri'

class Prefix < ActiveRecord::Base

  belongs_to :endpoint
  validates :uri, format: URI::regexp(%w(http https))
  validates :element_type, presence: true

  def self.import_csv(params)
    prefixes = []
    CSV.parse(params[:endpoint][:file].read, {headers: true}).each do |row|
      prefix = Prefix.new
      prefix.endpoint_id = params[:id]
      prefix.uri = NKF::nkf("-w", row[0].to_s)
      prefix.element_type = params[:endpoint][:element_type]
      unless prefix.valid?
        return "Failed to import. #{prefix.uri} is invalid URI. URI must start with 'http://' or 'https://'."
      end
      prefixes.push(prefix)
    end
    prefixes.each{|prefix| prefix.save}
    nil
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
    nil
  end

end
