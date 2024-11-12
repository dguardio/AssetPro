FactoryBot.define do
  factory :location do
    name { Faker::Address.unique.community }
    address { Faker::Address.street_address }
    building { Faker::Address.building_number }
    floor { Faker::Number.between(from: 1, to: 10).to_s }
    room { "Room #{Faker::Number.between(from: 100, to: 999)}" }
  end
end 