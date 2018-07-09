FactoryBot.define do
  factory :relation do
    sequence :endpoint_id { |n| n }

    sequence :dst_id { |n| n + 1 }

    name {["seeAlso","sameAs"].sample}
  end

end
