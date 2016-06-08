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

  def self.different?(previous, latest, logger: nil)
    log = Umakadata::Logging::Log.new
    logger.push log unless logger.nil?

    if previous.nil?
      log.result = 'The previous status is nothing'
      return true
    elsif latest.nil?
      log.result = 'The previous status and latest one are nothing'
      return true
    end

    if previous[:count] != latest[:count]
      log.result = "The previous statements count #{previous[:count]}, latest statements count #{latest[:count]}"
    elsif previous[:first] != latest[:first]
      log.result = "The previous first statement #{previous[:first]}, latest last statement #{latest[:first]}"
    elsif previous[:last] != latest[:last]
      log.result = "The previous last statement #{previous[:last]}, latest last statement  #{latest[:last]}"
    else
      log.result = 'There are no differences between previous statements and latest ones'
      return false
    end

    return true
  end

end
