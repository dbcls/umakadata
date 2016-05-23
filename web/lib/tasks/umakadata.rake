namespace :umakadata do

  desc "check endpoint liveness"
  task :crawl => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      retriever = Umakadata::Retriever.new endpoint.url
      Evaluation.record(endpoint, retriever)
    end
  end

  desc "test for checking endpoint liveness"
  task :test_crawl, ['name'] => :environment do |task, args|
    endpoint = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    puts endpoint.name
    retriever = Umakadata::Retriever.new endpoint.url
    Evaluation.record(endpoint, retriever)
  end

  desc "test for checking retriever method all endpoints"
  task :retriever_method, ['method_name'] => :environment do |task, args|
    puts "endpoint_name|dead/alive|result|log"
    Endpoint.all.each do |endpoint|
      retriever = Umakadata::Retriever.new endpoint.url

      if retriever.alive?
        logger = Umakadata::Logging::Log.new
        puts endpoint.name + "|alive|" + retriever.send(args[:method_name], logger: logger).to_s + "|" + logger.as_json.to_s
      else
        puts endpoint.name + "|dead|x|x|"
      end
    end
  end

  desc "test for checking retriever method"
  task :test_retriever_method, ['name', 'method_name'] => :environment do |task, args|
    puts "endpoint_name|dead/alive|result|log"
    endpoint = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    retriever = Umakadata::Retriever.new endpoint.url

    if retriever.alive?
      logger = Umakadata::Logging::Log.new
      puts endpoint.name + "|alive|" + retriever.send(args[:method_name], logger: logger).to_s + "|" + logger.as_json.to_s
    else
      puts endpoint.name + "|dead|x|x|"
    end
  end

end
