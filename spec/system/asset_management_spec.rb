require 'rails_helper'

RSpec.describe 'Asset Management', type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:category) { create(:category) }
  let!(:location) { create(:location) }
  
  before do
    driven_by(:rack_test)
    sign_in admin
  end

  it 'allows creating a new asset' do
    visit new_asset_path
    
    fill_in 'Name', with: 'Test Asset'
    fill_in 'Description', with: 'Test Description'
    select 'available', from: 'Status'
    select category.name, from: 'Category'
    select location.name, from: 'Location'
    
    expect {
      click_button 'Create Asset'
    }.to change(Asset, :count).by(1)
    
    expect(page).to have_content('Asset was successfully created')
  end

  context 'with existing asset' do
    let!(:asset) { create(:asset) }

    it 'allows assigning RFID tag' do
      visit asset_path(asset)
      click_link 'Assign RFID Tag'
      
      fill_in 'Rfid number', with: 'TEST123'
      click_button 'Assign RFID Tag'
      
      expect(page).to have_content('RFID tag was successfully assigned')
      expect(asset.reload.rfid_tag).to be_present
    end
  end
end 