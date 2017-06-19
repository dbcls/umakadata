FactoryGirl.define do
  factory :evaluation do
    sequence(:created_at) {|n| n.days.ago(Time.zone.now)}
  end

end
