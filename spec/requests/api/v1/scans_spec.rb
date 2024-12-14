require 'swagger_helper'

RSpec.describe 'API V1', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/scans' do
    post 'Create a new scan' do
      tags 'Scans'
      security [oauth2: ['write']]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :scan, in: :body, schema: {
        type: :object,
        properties: {
          rfid_number: { type: :string },
          location_id: { type: :integer },
          event_type: { type: :string, enum: ['movement', 'check_in', 'check_out'] },
          notes: { type: :string }
        },
        required: ['rfid_number', 'location_id']
      }

      response '201', 'scan created' do
        let(:scan) { { rfid_number: 'ABC123', location_id: 1 } }
        run_test!
      end

      response '401', 'unauthorized' do
        run_test!
      end
    end
  end
end 