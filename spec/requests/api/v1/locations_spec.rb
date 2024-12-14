require 'swagger_helper'

RSpec.describe 'API V1 Locations', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/locations' do
    get 'Lists all locations' do
      tags 'Locations'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      
      response '200', 'locations found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  description: { type: :string },
                  address: { type: :string },
                  building: { type: :string },
                  floor: { type: :string },
                  room: { type: :string },
                  created_at: { type: :string, format: 'date-time' },
                  updated_at: { type: :string, format: 'date-time' },
                  asset_count: { type: :integer },
                  assets: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: { type: :integer },
                        name: { type: :string },
                        asset_code: { type: :string }
                      }
                    }
                  }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                total_pages: { type: :integer },
                total_count: { type: :integer }
              }
            }
          }
        
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end
  end

  path '/api/v1/locations/{id}' do
    get 'Retrieves a location' do
      tags 'Locations'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer

      response '200', 'location found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                description: { type: :string },
                address: { type: :string },
                building: { type: :string },
                floor: { type: :string },
                room: { type: :string },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                asset_count: { type: :integer },
                assets: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string },
                      asset_code: { type: :string }
                    }
                  }
                },
                asset_tracking_events: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      event_type: { type: :string },
                      scanned_at: { type: :string, format: 'date-time' }
                    }
                  }
                }
              }
            }
          }

        let(:id) { create(:location).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end

      response '404', 'location not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end
end 