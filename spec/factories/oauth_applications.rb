FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { 'Test Application' }
    redirect_uri { 'urn:ietf:wg:oauth:2.0:oob' }
    scopes { 'read write' }
    organization_name { 'Test Organization' }
  end
end 