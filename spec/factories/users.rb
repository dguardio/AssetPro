FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    email { Faker::Internet.email }
    password { 'password' }
    role { 'admin' }

    trait :admin do
      role { 'admin' }
    end

    trait :security do
      role { 'security' }
    end
  end
end 