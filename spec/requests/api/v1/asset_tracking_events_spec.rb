require 'swagger_helper'

RSpec.describe 'API V1 Asset Tracking Events', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/asset_tracking_events' do
    get 'Lists all asset tracking events' do
      tags 'Asset Tracking Events'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      
      response '200', 'events found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  event_type: { type: :string },
                  rfid_number: { type: :string },
                  scanned_at: { type: :string, format: 'date-time' },
                  notes: { type: :string },
                  created_at: { type: :string, format: 'date-time' },
                  updated_at: { type: :string, format: 'date-time' },
                  asset: { 
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string }
                    }
                  },
                  location: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string }
                    }
                  },
                  scanned_by: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      email: { type: :string }
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

    post 'Creates an asset tracking event' do
      tags 'Asset Tracking Events'
      security [oauth2: ['write']]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :event, in: :body, schema: {
        type: :object,
        properties: {
          asset_tracking_event: {
            type: :object,
            properties: {
              asset_id: { type: :integer },
              location_id: { type: :integer },
              event_type: { 
                type: :string, 
                enum: ['movement', 'check_in', 'check_out', 'assigned']
              },
              rfid_number: { type: :string },
              notes: { type: :string }
            },
            required: ['asset_id', 'location_id', 'event_type']
          }
        }
      }

      response '201', 'event created' do
        let(:event) { { 
          asset_tracking_event: {
            asset_id: create(:asset).id,
            location_id: create(:location).id,
            event_type: 'movement'
          }
        } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end

      response '422', 'invalid request' do
        let(:event) { { asset_tracking_event: { asset_id: nil } } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/asset_tracking_events/{id}' do
    get 'Retrieves an asset tracking event' do
      tags 'Asset Tracking Events'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer

      response '200', 'event found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                event_type: { type: :string },
                rfid_number: { type: :string },
                scanned_at: { type: :string, format: 'date-time' },
                notes: { type: :string },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                asset: { 
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string }
                  }
                },
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

        let(:id) { create(:asset_tracking_event).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end

      response '404', 'event not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/asset_tracking_events/timeline' do
    get 'Retrieves event timeline' do
      tags 'Asset Tracking Events'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      
      response '200', 'timeline retrieved' do
        schema type: :object,
          properties: {
            data: {
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
        
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end
end 