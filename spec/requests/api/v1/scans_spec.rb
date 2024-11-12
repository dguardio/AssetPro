require 'rails_helper'

RSpec.describe 'API V1 Scans', type: :request do
  let(:user) { create(:user, :security) }
  let(:asset) { create(:asset, :with_rfid) }
  let(:location) { create(:location) }

  before do
    sign_in user
  end

  describe 'POST /api/v1/scans' do
    let(:valid_params) do
      {
        scan: {
          rfid_number: asset.rfid_tag.rfid_number,
          location_id: location.id,
          event_type: 'location_update'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new tracking event' do
        expect {
          post '/api/v1/scans', params: valid_params
        }.to change(AssetTrackingEvent, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['status']).to eq('success')
      end
    end

    context 'with invalid RFID number' do
      it 'returns not found status' do
        post '/api/v1/scans', params: { 
          scan: valid_params[:scan].merge(rfid_number: 'INVALID') 
        }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end 