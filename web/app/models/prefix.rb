require "csv"
require "nkf"
require 'uri'

class Prefix < ActiveRecord::Base

  FORMAT_VALIDATOR = { with: URI::regexp(%w(http https ftp)), message: "URI must start with 'http://', 'https://' or 'ftp://." }.freeze

  belongs_to :endpoint
  validates :allow_regex, format: FORMAT_VALIDATOR, allow_blank: true
  validates :deny_regex, format: FORMAT_VALIDATOR, allow_blank: true
  validate :uri_present

  class FormatError < StandardError
  end

  def self.import_csv(params)
    prefixes = CSV.parse(params[:endpoint][:file].read, {headers: true}).map do |row|
      prefix = Prefix.new
      prefix.endpoint_id = params[:id]
      prefix.allow_regex = NKF::nkf("-w", row['URI'].to_s)
      prefix.deny_regex = NKF::nkf("-w", row['DENIED_URI'].to_s)
      case_sensitive = NKF::nkf("-w", row['CASE_SENSITIVE'].to_s)
      if case_sensitive.present?
        if %w(true false).include?(case_sensitive)
          prefix.case_sensitive = case_sensitive
        else
          raise FormatError.new("Failed to import: '#{case_sensitive}' is invalid as case sensitiveness. It must be true or false")
        end
      end

      unless prefix.valid?
        raise FormatError.new("Failed to import: #{prefix.errors.full_messages}")
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
    unless allow_regex.present? || deny_regex.present?
      errors.add(:base, "At least one of allowed_uri and denied_uri must be present.")
    end
  end
end
