class Crawler

  def self.check_endpoints
    Endpoint.all.each do |endpoint|
      checker = Yummydata::Endpoint.new endpoint.url
      log = CheckLog.new
      log.endpoint_id = endpoint.id
      log.alive = checker.alive?
      log.service_description = checker.service_description?
      log.save!
    end
  end

end
