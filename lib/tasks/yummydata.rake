namespace :yummydata do

  desc "check endpoint liveness"
  task :crawl => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      retriever = Yummydata::Retriever.new endpoint.url
      Evaluation.record(endpoint, retriever)
    end
  end

  desc "test"
  task :test => :environment do |variable|
    endpoint = Endpoint.first
    retriever = Yummydata::Retriever.new endpoint.url
    puts retriever.cool_uri_rate
  end
end
