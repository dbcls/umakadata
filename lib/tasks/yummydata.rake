namespace :yummydata do

  desc "check endpoint liveness"
  task :crawl => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      retriever = Yummydata::Retriever.new endpoint.url
      eval = Evaluation.record(endpoint, retriever)
      UpdateStatus.record(endpoint, retriever) if eval.alive?
    end
  end
end
