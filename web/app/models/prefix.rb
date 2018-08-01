require "csv"
require "nkf"
require 'uri'

class Prefix < ActiveRecord::Base

  belongs_to :endpoint
  validates :allowed_uri, format: URI::regexp(%w(http https ftp)), allow_blank: true
  validates :denied_uri, format: URI::regexp(%w(http https ftp)), allow_blank: true
  validate :uri_present

  class FormatError < StandardError
  end

  def self.import_csv(params)
    prefixes = CSV.parse(params[:endpoint][:file].read, {headers: true}).map do |row|
      prefix = Prefix.new
      prefix.endpoint_id = params[:id]
      prefix.allowed_uri = NKF::nkf("-w", row[0].to_s)
      prefix.denied_uri = NKF::nkf("-w", row[1].to_s)
      case_sensitive = NKF::nkf("-w", row[2].to_s)
      if case_sensitive.present?
        if %w(true false).include?(case_sensitive)
          prefix.case_sensitive = case_sensitive
        else
          raise FormatError.new("Failed to import: '#{case_sensitive}' is invalid as case sensitiveness. It must be true or false")
        end
      end

      unless prefix.valid?
        raise FormatError.new("Failed to import: #{prefix.errors.full_messages} URI must start with 'http://', 'https://' or 'ftp://'.")
      end
      prefix
    end
    prefixes.each{ |prefix| prefix.save }
    nil
  end

  def self.validates_params(params)
    if params[:endpoint].nil?
      return 'CSV file is required'
    end
    nil
  end


  private

  def uri_present
    unless allowed_uri.present? || denied_uri.present?
      errors.add(:base, "At least one of allowed_uri and denied_uri must be present.")
    end
  end

end
