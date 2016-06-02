class UpdateStatus < ActiveRecord::Base

  belongs_to :endpoint

  def self.record(endpoint_id, latest)
    status = UpdateStatus.new
    status[:endpoint_id] = endpoint_id
    status[:count] = latest[:count]
    status[:first] = latest[:first].nil? ? '' : latest[:first].map{ |k, v| v }.join('$')
    status[:last]  = latest[:last].nil?  ? '' : latest[:last].map{ |k, v| v }.join('$')
    status.save
    return status
  end

  def self.different?(lhs, rhs, logger: nil)
    log = Umakadata::Logging::Log.new
    logger.push log unless logger.nil?

    if lhs.nil?
      log.result = 'The previous status is nothing'
      return true
    elsif rhs.nil?
      log.result = 'The previous status and latest one are nothing'
      return true
    end

    if lhs[:count] != rhs[:count]
      log.result = "The previous statements count #{lhs[:count]}, latest statements count #{rhs[:count]}"
    elsif lhs[:first] != rhs[:first]
      log.result = "The previous first statement #{lhs[:first]}, latest last statement #{rhs[:first]}"
    elsif lhs[:last] != rhs[:last]
      log.result = "The previous last statement #{lhs[:last]}, latest last statement  #{rhs[:last]}"
    else
      log.result = 'Difference is nothing both of previous statements and latest statements'
      return false
    end

    return true
  end

end
