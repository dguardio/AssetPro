require 'rails_helper'

RSpec.describe Asset, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:status) }
    it { should belong_to(:category) }
    it { should belong_to(:location).optional }
    it { should have_one(:rfid_tag) }
    it { should have_many(:asset_tracking_events) }
  end

  describe 'scopes' do
    let!(:available_asset) { create(:asset, status: 'available') }
    let!(:in_use_asset) { create(:asset, status: 'in_use') }
    
    it 'filters available assets' do
      expect(Asset.available).to include(available_asset)
      expect(Asset.available).not_to include(in_use_asset)
    end
  end

  describe '#assign_rfid_tag!' do
    let(:asset) { create(:asset) }
    
    it 'creates an RFID tag and enables RFID' do
      asset.assign_rfid_tag!('ABC123')
      expect(asset.rfid_enabled).to be true
      expect(asset.rfid_tag.rfid_number).to eq('ABC123')
    end
  end
end 