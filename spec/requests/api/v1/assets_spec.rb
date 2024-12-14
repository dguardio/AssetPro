require 'swagger_helper'

RSpec.describe 'API V1 Assets', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/assets' do
    get 'Lists all assets' do
      tags 'Assets'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      
      response '200', 'assets found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  asset_code: { type: :string },
                  status: { type: :string, enum: ['available', 'in_use', 'maintenance'] },
                  description: { type: :string },
                  location: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      name: { type: :string }
                    }
                  },
                  rfid_tag: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      rfid_number: { type: :string }
                    }
                  }
                }
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

  path '/api/v1/assets/{id}' do
    get 'Retrieves an asset' do
      tags 'Assets'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer

      response '200', 'asset found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                name: { type: :string },
                asset_code: { type: :string },
                status: { type: :string },
                description: { type: :string },
                location: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string }
                  }
                },
                rfid_tag: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    rfid_number: { type: :string }
                  }
                }
              }
            }
          }

        let(:id) { create(:asset).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end

      response '404', 'asset not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/assets/{id}/history' do
    get 'Retrieves asset history' do
      tags 'Assets'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer
      
      response '200', 'history retrieved' do
        schema type: :object,
          properties: {
            data: {
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
            }
          }
        
        let(:id) { create(:asset).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/assets/search' do
    get 'Search assets' do
      tags 'Assets'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :q, in: :query, type: :string, required: true, description: 'Search query'
      
      response '200', 'search results' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  asset_code: { type: :string },
                  status: { type: :string }
                }
              }
            }
          }
        
        let(:q) { 'test' }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end
  end
end 