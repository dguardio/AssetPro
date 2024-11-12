FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { 'user' }
    
    trait :admin do
      role { 'admin' }
    end
    
    trait :security do
      role { 'security' }
    end

    trait :manager do
      role { 'manager' }
    end
  end
end 