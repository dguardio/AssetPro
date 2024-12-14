class RfidReaderSerializer < ActiveModel::Serializer
  attributes :id,
             :reader_id,
             :name,
             :position,
             :active,
             :last_ping_at,
             :created_at,
             :updated_at

  belongs_to :oauth_application
end 