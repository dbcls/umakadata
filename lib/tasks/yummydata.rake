namespace :yummydata do

  desc "check endpoint liveness"
  task :crawl => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      retriever = Yummydata::Retriever.new endpoint.url
      Evaluation.record(endpoint, retriever)
    end
  end

  desc "test for checking endpoint liveness"
  task :test_crawl, ['name'] => :environment do |task, args|
    endpoint = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    puts endpoint.name
    retriever = Yummydata::Retriever.new endpoint.url
    Evaluation.record(endpoint, retriever)
  end

end
