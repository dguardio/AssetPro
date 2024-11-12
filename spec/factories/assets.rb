FactoryBot.define do
  factory :asset do
    name { Faker::Commerce.product_name }
    asset_code { Faker::Alphanumeric.alphanumeric(number: 10).upcase }
    status { 'available' }
    association :category
    association :location
    
    trait :with_rfid do
      rfid_enabled { true }
      after(:create) do |asset|
        create(:rfid_tag, asset: asset)
      end
    end

    trait :in_use do
      status { 'in_use' }
    end

    trait :in_maintenance do
      status { 'in_maintenance' }
    end

    trait :retired do
      status { 'retired' }
    end
  end
end
