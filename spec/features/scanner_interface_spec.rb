require 'rails_helper'

RSpec.describe 'Scanner Interface', type: :feature do
  let(:security_user) { create(:user, :security) }
  let!(:location) { create(:location) }
  
  before do
    sign_in security_user
    visit scanner_path
  end

  it 'displays the scanner interface' do
    expect(page).to have_content('Asset Scanner')
    expect(page).to have_select('location')
    expect(page).to have_button('Start Scanning')
  end

  it 'toggles scanning mode', js: true do
    click_button 'Start Scanning'
    expect(page).to have_button('Stop Scanning')
    
    click_button 'Stop Scanning'
    expect(page).to have_button('Start Scanning')
  end
end 