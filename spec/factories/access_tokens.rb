FactoryBot.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    application { create(:oauth_application) }
    resource_owner_id { create(:user).id }
    scopes { 'read' }
    expires_in { 2.hours }
  end
end 