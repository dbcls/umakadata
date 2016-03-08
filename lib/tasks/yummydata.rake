namespace :yummydata do

  desc "check endpoint liveness"
  task :crawl => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      retriever = Yummydata::Retriever.new endpoint.url
      Evaluation.record(endpoint, retriever)
    end
  end
end
