class UpdateStatus < ActiveRecord::Base

  belongs_to :endpoint

  def self.record(endpoint_id, current)
    status = UpdateStatus.new
    status[:endpoint_id] = endpoint_id
    status[:count] = current[:count]
    status[:first] = current[:first].nil? ? '' : current[:first].map{ |k, v| v }.join('$')
    status[:last]  = current[:last].nil?  ? '' : current[:last].map{ |k, v| v }.join('$')
    status.save
    return status
  end

  def self.different?(lhs, rhs)
    return true if lhs.nil? || rhs.nil?
    return lhs[:count] != rhs[:count] || lhs[:first] != rhs[:first] || lhs[:last] != rhs[:last]
  end

end
