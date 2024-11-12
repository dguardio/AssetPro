# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Clear existing data
puts "Clearing existing data..."
AssetTrackingEvent.destroy_all
RfidTag.destroy_all
Asset.destroy_all
Location.destroy_all
Category.destroy_all
User.destroy_all

# Create users
puts "Creating users..."
admin = User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin'
)

security = User.create!(
  email: 'security@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'security'
)

manager = User.create!(
  email: 'manager@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'manager'
)

# Create locations
puts "Creating locations..."
locations = [
  Location.create!(
    name: 'Main Building - Floor 1',
    building: 'Main Building',
    floor: '1',
    address: '123 Main St, Suite 100',
    room: '101'
  ),
  Location.create!(
    name: 'Main Building - Floor 2',
    building: 'Main Building',
    floor: '2',
    address: '123 Main St, Suite 200',
    room: '201'
  ),
  Location.create!(
    name: 'Warehouse A',
    building: 'Warehouse',
    floor: '1',
    address: '456 Storage Ave',
    room: 'WH-A'
  ),
  Location.create!(
    name: 'IT Department',
    building: 'Main Building',
    floor: '3',
    address: '123 Main St, Suite 300',
    room: '301'
  ),
  Location.create!(
    name: 'Research Lab',
    building: 'R&D Building',
    floor: '1',
    address: '789 Innovation Pkwy',
    room: 'Lab-1'
  )
]

# Create categories
puts "Creating categories..."
categories = [
  Category.create!(name: 'Laptops', description: 'Portable computers'),
  Category.create!(name: 'Monitors', description: 'Display screens'),
  Category.create!(name: 'Office Furniture', description: 'Chairs, desks, etc.'),
  Category.create!(name: 'Network Equipment', description: 'Routers, switches, etc.'),
  Category.create!(name: 'Lab Equipment', description: 'Scientific instruments')
]

# Create assets
puts "Creating assets..."
20.times do |i|
  asset = Asset.create!(
    name: "Asset #{i+1}",
    description: Faker::Lorem.sentence,
    status: Asset.statuses.keys.sample,
    category: categories.sample,
    location: locations.sample,
    asset_code: "ASSET-#{sprintf('%04d', i+1)}"
  )

  # Add RFID tags to some assets
  if i.even?
    rfid_tag = RfidTag.create!(
      asset: asset,
      rfid_number: "RFID#{sprintf('%06d', i+1)}",
      active: true,
      last_known_location: asset.location
    )
    asset.update(rfid_enabled: true)

    # Create some tracking events
    3.times do |j|
      AssetTrackingEvent.create!(
        asset: asset,
        location: locations.sample,
        rfid_number: rfid_tag.rfid_number,
        event_type: 'location_update',
        scanned_by: security,
        scanned_at: j.days.ago
      )
    end
  end
end

puts "\nSeed data created successfully!"
puts "\nTest user credentials:"
puts "Admin - Email: admin@example.com, Password: password123"
puts "Security - Email: security@example.com, Password: password123"
puts "Manager - Email: manager@example.com, Password: password123"
