require 'swagger_helper'

RSpec.describe 'API V1 RFID Tags', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/rfid_tags/{id}' do
    get 'Retrieves an RFID tag' do
      tags 'RFID Tags'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer, required: true, 
                description: 'RFID tag ID'

      response '200', 'rfid tag found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                rfid_number: { type: :string },
                active: { type: :boolean },
                last_scanned_at: { 
                  type: :string, 
                  format: 'date-time',
                  nullable: true 
                },
                location_id: { 
                  type: :integer,
                  nullable: true 
                },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                asset: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string },
                    asset_code: { type: :string }
                  }
                },
                last_known_location: {
                  type: :object,
                  nullable: true,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string }
                  }
                },
                asset_tracking_events: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      event_type: { type: :string },
                      scanned_at: { type: :string, format: 'date-time' },
                      location: {
                        type: :object,
                        properties: {
                          id: { type: :integer },
                          name: { type: :string }
                        }
                      }
                    }
                  }
                }
              }
            }
          }

        let(:id) { create(:rfid_tag).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:id) { create(:rfid_tag).id }
        run_test!
      end

      response '404', 'rfid tag not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end
end 