class RfidReader < ApplicationRecord
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', optional: true
  has_many :asset_tracking_events, foreign_key: 'rfid_reader_id'

  scope :active, -> { where(active: true) }

  validates :reader_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :position, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[active created_at id last_ping_at name oauth_application_id position reader_id updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[oauth_application asset_tracking_events]
  end

  def self.register_ping(reader_id)
    reader = find_or_create_by(reader_id: reader_id) do |r|
      r.name = "Reader #{reader_id}"
      r.position = "Unknown"
    end
    reader.update(last_ping_at: Time.current)
    reader
  end

  def can_receive_scans?
    active?
  end
end 