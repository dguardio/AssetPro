require 'swagger_helper'

RSpec.describe 'API V1 RFID Readers', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/rfid_readers/{id}' do
    get 'Retrieves an RFID reader' do
      tags 'RFID Readers'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer, required: true, 
                description: 'RFID reader ID'

      response '200', 'rfid reader found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                reader_id: { type: :string },
                name: { type: :string },
                position: { type: :string },
                active: { type: :boolean },
                last_ping_at: { 
                  type: :string, 
                  format: 'date-time',
                  nullable: true 
                },
                created_at: { type: :string, format: 'date-time' },
                updated_at: { type: :string, format: 'date-time' },
                oauth_application: {
                  type: :object,
                  properties: {
                    id: { type: :integer },
                    name: { type: :string }
                  }
                }
              }
            }
          }

        let(:id) { create(:rfid_reader).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end

      response '404', 'reader not found' do
        let(:id) { 'invalid' }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end

    patch 'Updates an RFID reader' do
      tags 'RFID Readers'
      security [oauth2: ['write']]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer, required: true
      parameter name: :reader, in: :body, schema: {
        type: :object,
        properties: {
          rfid_reader: {
            type: :object,
            properties: {
              name: { type: :string },
              position: { type: :string },
              active: { type: :boolean }
            }
          }
        }
      }

      response '200', 'reader updated' do
        let(:id) { create(:rfid_reader).id }
        let(:reader) { { rfid_reader: { name: 'Updated Reader' } } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end

      response '422', 'invalid request' do
        let(:id) { create(:rfid_reader).id }
        let(:reader) { { rfid_reader: { name: '' } } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/rfid_readers/ping' do
    post 'Updates reader heartbeat status' do
      tags 'RFID Readers'
      security [oauth2: ['write']]
      consumes 'application/json'
      produces 'application/json'

      response '200', 'ping successful' do
        schema type: :object,
          properties: {
            status: { type: :string },
            server_time: { type: :string, format: 'date-time' },
            reader: {
              type: :object,
              properties: {
                id: { type: :integer },
                reader_id: { type: :string },
                name: { type: :string },
                position: { type: :string },
                active: { type: :boolean },
                last_ping_at: { type: :string, format: 'date-time' }
              }
            }
          }

        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end

      response '404', 'reader not found' do
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end
  end
end 