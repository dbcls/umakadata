require "csv"
require "nkf"
require 'uri'

class Prefix < ActiveRecord::Base

  belongs_to :endpoint

  FORMAT_VALIDATOR = { with: URI::regexp(%w(http https ftp)), message: "URI must start with 'http://', 'https://' or 'ftp://." }.freeze
  validates :endpoint, presence: true
  validates :allow, format: FORMAT_VALIDATOR, allow_blank: true
  validates :deny, format: FORMAT_VALIDATOR, allow_blank: true
  validates :fixed_uri, format: FORMAT_VALIDATOR, allow_blank: true
  validate :uri_present

  class FormatError < StandardError
  end

  def self.import_csv(params)
    prefixes = CSV.parse(params[:endpoint][:file].read, {headers: true}).map do |row|
      prefix = Prefix.new
      prefix.endpoint_id = params[:id]
      prefix.allow = NKF::nkf("-w", row['URI'].to_s)
      prefix.deny = NKF::nkf("-w", row['DENIED_URI'].to_s)
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

  # def endpoint_selection
  #   if endpoint_id.blank?
  #     errors.add(:endpoint_id, "must not be empty.")
  #   end
  # end

  def uri_present
    if use_fixed_uri
      if fixed_uri.blank?
        errors.add(:fixed_uri, "can't be blank.")
      end
    else
      if [allow, deny].all?(&:blank?)
        errors.add(:base, "At least one of \"Allow\" and \"Deny\" must be entered.")
      end
    end
  end
end
