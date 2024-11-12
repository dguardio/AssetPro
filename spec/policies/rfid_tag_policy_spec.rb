require 'rails_helper'

RSpec.describe RfidTagPolicy do
  subject { described_class.new(user, rfid_tag) }

  let(:rfid_tag) { create(:rfid_tag) }

  context 'being an admin' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
  end

  context 'being a security user' do
    let(:user) { create(:user, :security) }

    it { is_expected.to forbid_action(:create) }
    it { is_expected.to forbid_action(:destroy) }
  end
end 