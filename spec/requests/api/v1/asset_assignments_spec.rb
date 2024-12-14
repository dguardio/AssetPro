require 'swagger_helper'

RSpec.describe 'API V1 Asset Assignments', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/asset_assignments' do
    get 'Lists all asset assignments' do
      tags 'Asset Assignments'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      
      response '200', 'assignments found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  checked_out_at: { type: :string, format: 'date-time', nullable: true },
                  checked_in_at: { type: :string, format: 'date-time', nullable: true },
                  expected_return_date: { type: :string, format: 'date', nullable: true },
                  notes: { type: :string },
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
                  user: {
                    type: :object,
                    properties: {
                      id: { type: :integer },
                      email: { type: :string }
                    }
                  },
                  assigned_by: {
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
    end

    post 'Creates an asset assignment' do
      tags 'Asset Assignments'
      security [oauth2: ['write']]
      consumes 'application/json'
      produces 'application/json'

      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          asset_assignment: {
            type: :object,
            properties: {
              asset_id: { type: :integer },
              user_id: { type: :integer },
              expected_return_date: { type: :string, format: 'date' },
              notes: { type: :string }
            },
            required: ['asset_id', 'user_id']
          }
        }
      }

      response '201', 'assignment created' do
        let(:assignment) { { 
          asset_assignment: {
            asset_id: create(:asset).id,
            user_id: create(:user).id
          }
        } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end

      response '422', 'invalid request' do
        let(:assignment) { { asset_assignment: { asset_id: nil } } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/asset_assignments/{id}' do
    get 'Retrieves an asset assignment' do
      tags 'Asset Assignments'
      security [oauth2: ['read']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer

      response '200', 'assignment found' do
        schema type: :object,
          properties: {
            data: {
              type: :object,
              properties: {
                id: { type: :integer },
                checked_out_at: { type: :string, format: 'date-time', nullable: true },
                checked_in_at: { type: :string, format: 'date-time', nullable: true },
                expected_return_date: { type: :string, format: 'date', nullable: true },
                notes: { type: :string }
              }
            }
          }

        let(:id) { create(:asset_assignment).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'read').token}" }
        run_test!
      end
    end

    patch 'Updates an asset assignment' do
      tags 'Asset Assignments'
      security [oauth2: ['write']]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer
      parameter name: :assignment, in: :body, schema: {
        type: :object,
        properties: {
          asset_assignment: {
            type: :object,
            properties: {
              expected_return_date: { type: :string, format: 'date' },
              notes: { type: :string }
            }
          }
        }
      }

      response '200', 'assignment updated' do
        let(:id) { create(:asset_assignment).id }
        let(:assignment) { { asset_assignment: { notes: 'Updated notes' } } }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/asset_assignments/{id}/check_out' do
    post 'Checks out an asset assignment' do
      tags 'Asset Assignments'
      security [oauth2: ['write']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer

      response '200', 'asset checked out' do
        let(:id) { create(:asset_assignment).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end
    end
  end

  path '/api/v1/asset_assignments/{id}/check_in' do
    post 'Checks in an asset assignment' do
      tags 'Asset Assignments'
      security [oauth2: ['write']]
      produces 'application/json'
      
      parameter name: :id, in: :path, type: :integer

      response '200', 'asset checked in' do
        let(:id) { create(:asset_assignment).id }
        let(:Authorization) { "Bearer #{create(:access_token, scopes: 'write').token}" }
        run_test!
      end
    end
  end
end 