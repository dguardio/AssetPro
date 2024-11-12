FactoryBot.define do
  factory :account_status_log do
    user { nil }
    changed_by { nil }
    status_from { false }
    status_to { false }
    reason { "MyText" }
  end
end
