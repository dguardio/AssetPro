FactoryBot.define do
  factory :rfid_tag do
    rfid_number { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    active { true }
    association :asset
    association :last_known_location, factory: :location
  end
end 