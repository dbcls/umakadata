FactoryGirl.define do
  factory :relation do
    endpoint_id {rand(1..Endpoint.all.count)}
    dst_id {
      rand_dst_id = rand(1..Endpoint.all.count)
      while endpoint_id == rand_dst_id
        rand_dst_id = rand(1..Endpoint.all.count)
      end
      rand_dst_id
    }
    name {["seeAlso","sameAs"].sample}
  end

end
