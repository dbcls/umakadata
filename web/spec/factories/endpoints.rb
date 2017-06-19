FactoryGirl.define do
  factory :endpoint do
    sequence(:name){|n| "Endpoint #{n}"}
    sequence(:url){|n| "http://example#{n}.com"}
  end
end
