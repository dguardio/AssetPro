require 'faker'

# Set locale for consistent data
Faker::Config.locale = 'en'

# Create Current class if it doesn't exist
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

# Define valid roles and statuses
VALID_ROLES = ['admin', 'manager', 'user', 'security']
ASSET_STATUSES = ['available', 'in_maintenance', 'retired', 'in_use']

# Define maintenance types
MAINTENANCE_TYPES = ['preventive', 'corrective', 'inspection']  # Make sure these match your enum

puts "Cleaning database..."

# Disable auditing during seeding
$skip_auditing = true

# Clear the database
[
  AssetAssignment, MaintenanceSchedule, MaintenanceRecord, 
  License, RfidTag, AssetTrackingEvent, AccountStatusLog, 
  AuditLog, Asset, Category, Location, User, Role
].each do |model|
  puts "Deleting #{model.name.pluralize}..."
  model.unscoped.delete_all
end

# Create roles first
puts "Creating roles..."
VALID_ROLES.each do |role_name|
  Role.create!(name: role_name)
  puts "Created #{role_name} role"
end

# Create admin user first
puts "Creating admin user..."
admin = User.new(
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: 'admin',
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  active: true,
  sign_in_count: rand(1..50),
  current_sign_in_at: Faker::Time.between(from: 1.day.ago, to: Time.current),
  last_sign_in_at: Faker::Time.between(from: 1.month.ago, to: 2.days.ago)
)
admin.save(validate: false)
admin.add_role(:admin)

# Set admin as current user
Current.user = admin

# Enable auditing for the rest of the seed
$skip_auditing = false

# Create regular users
puts "Creating users..."
users = 20.times.map do |i|
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  role = ['manager', 'user', 'security'][i % 3]

  user = User.new(
    email: Faker::Internet.email(name: "#{first_name} #{last_name}"),
    password: 'password',
    password_confirmation: 'password',
    role: role,
    first_name: first_name,
    last_name: last_name,
    active: true,
    sign_in_count: rand(1..100),
    current_sign_in_at: Faker::Time.between(from: 1.day.ago, to: Time.current),
    last_sign_in_at: Faker::Time.between(from: 1.month.ago, to: 2.days.ago),
    current_sign_in_ip: Faker::Internet.ip_v4_address,
    last_sign_in_ip: Faker::Internet.ip_v4_address
  )
  user.save(validate: false)
  user.add_role(role.to_sym)
  user
end

# Create categories
puts "Creating categories..."
categories = 10.times.map do
  name = Faker::Commerce.unique.department(max: 1)
  Category.create!(
    name: name,
    description: Faker::Lorem.paragraph
  )
end

# Create locations (15 locations)
puts "Creating locations..."
locations = 15.times.map do
  building = ["HQ", "Branch", "Lab", "Warehouse"].sample
  Location.create!(
    name: Faker::Company.unique.name,
    address: Faker::Address.full_address,
    building: building,
    floor: rand(1..5).to_s,
    room: "#{rand(100..999)}",
    active: true
  )
end

# Create assets (50 assets)
puts "Creating assets..."
assets = 50.times.map do |i|
  quantity = rand(1..10)
  asset = Asset.create!(
    name: Faker::Computer.stack,
    description: Faker::Lorem.paragraph,
    asset_code: "AST-#{format('%04d', i+1)}",
    status: ASSET_STATUSES.sample,
    purchase_date: Faker::Date.between(from: 2.years.ago, to: Date.today),
    purchase_price: Faker::Commerce.price(range: 100..5000.0),
    category: categories.sample,
    location: locations.sample,
    rfid_enabled: Faker::Boolean.boolean(true_ratio: 0.7),
    last_tracked_at: Faker::Time.between(from: 6.months.ago, to: Time.current),
    depreciation_rate: rand(10.0..30.0).round(2),
    quantity: quantity,
    minimum_quantity: [1, quantity - rand(1..3)].max
  )

  # Create RFID tag for enabled assets
  if asset.rfid_enabled?
    RfidTag.create!(
      rfid_number: "RFID-#{SecureRandom.hex(6).upcase}",
      active: true,
      asset: asset,
      location_id: asset.location_id,
      last_scanned_at: Faker::Time.between(from: 1.month.ago, to: Time.current)
    )
  end

  asset
end

# Create asset assignments
puts "Creating asset assignments..."
manager = users.find { |u| u.has_role?(:manager) }
available_assets = assets.select { |a| a.status == 'available' }

30.times do
  asset = available_assets.sample
  # next unless asset && asset.available_quantity > 0
  next unless asset && asset.status == 'available'

  # First create the check-out time
  checked_out_at = Faker::Time.between(from: 1.month.ago, to: 1.week.ago)
  
  # Then create check-in time that's definitely after check-out
  checked_in_at = [
    nil,
    Faker::Time.between(from: checked_out_at, to: Time.current)
  ].sample
  
  AssetAssignment.create!(
    asset: asset,
    user: users.sample,
    assigned_by: manager,
    checked_out_at: checked_out_at,
    checked_in_at: checked_in_at,
    notes: Faker::Lorem.sentence
  )
end

# Create asset requests
puts "Creating asset requests..."
manager = users.find { |u| u.has_role?(:manager) }
available_assets = Asset.where(status: 'available')

20.times do
  # Only use available assets for requests
  asset = available_assets.sample
  next unless asset
  
  user = users.sample
  
  # Calculate request dates that make sense
  base_date = Date.today + rand(1..30).days
  requested_from = base_date
  requested_until = requested_from + rand(1..14).days
  
  begin
    request = AssetRequest.new(
      user: user,
      asset: asset,
      purpose: ["Development work", "Testing", "Client demo", "Training", "Backup device"].sample,
      requested_from: requested_from,
      requested_until: requested_until,
      status: ['pending', 'approved', 'rejected', 'cancelled'].sample
    )
    
    # Skip notifications during seeding
    request.define_singleton_method(:notify_managers) { }
    request.define_singleton_method(:notify_status_change) { }
    
    request.save!
    
    # Add review details for non-pending requests
    if request.status != 'pending'
      request.update!(
        reviewed_by: manager,
        reviewed_at: Time.current,
        rejection_reason: request.rejected? ? "Asset unavailable during requested period" : nil
      )
    end
    
    # If request is approved, mark asset as in_use
    if request.approved?
      asset.update!(status: 'in_use')
      available_assets = available_assets.where.not(id: asset.id)
    end
  rescue ActiveRecord::RecordInvalid => e
    puts "Skipping invalid request: #{e.message}"
    next
  end
end

puts "Created #{AssetRequest.count} asset requests"


# Create maintenance schedules (30 schedules)
puts "Creating maintenance schedules..."
30.times do
  asset = assets.sample
  frequency = ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'].sample
  next_due_at = Faker::Time.between(from: Time.current, to: 6.months.from_now)
  status = ['pending', 'in_progress', 'completed', 'overdue', 'cancelled'].sample

  MaintenanceSchedule.create!(
    title: "Maintenance for #{asset.name}",
    description: Faker::Lorem.paragraph,
    asset: asset,
    assigned_to: users.sample,
    status: status,
    notes: Faker::Lorem.paragraph,
    frequency: frequency,
    next_due_at: next_due_at,
    last_performed_at: Faker::Boolean.boolean(true_ratio: 0.3) ? 
      Faker::Time.between(from: 6.months.ago, to: next_due_at) : nil,
    completed_date: Faker::Boolean.boolean(true_ratio: 0.3) ? 
      Faker::Time.between(from: 6.months.ago, to: next_due_at) : nil
  )
end

# Create maintenance records (60 records)
puts "Creating maintenance records..."
maintenance_assets = assets.select { |a| a.status == 'in_maintenance' }

20.times do
  asset = maintenance_assets.sample || assets.sample
  
  MaintenanceRecord.create!(
    asset: asset,
    maintenance_type: MAINTENANCE_TYPES.sample.downcase,
    description: Faker::Lorem.paragraph,
    scheduled_date: Faker::Date.between(from: 2.months.ago, to: 1.month.from_now),
    completed_date: [nil, Faker::Date.between(from: 1.month.ago, to: Date.today)].sample,
    cost: Faker::Commerce.price(range: 50..500.0),
    performed_by: users.sample
  )

  # Update asset status if maintenance is not completed
  if asset.maintenance_records.where(completed_date: nil).any?
    asset.update!(status: 'in_maintenance')
  end
end

# Create licenses
puts "Creating licenses..."
licenses = 25.times.map do
  expiration_date = Faker::Date.between(from: 6.months.from_now, to: 2.years.from_now)
  seats = rand(5..50)
  seats_used = rand(0..seats)
  
  License.create!(
    name: Faker::App.name,
    description: Faker::Lorem.paragraph,
    license_key: "LIC-#{SecureRandom.hex(8).upcase}",
    seats: seats,
    seats_used: seats_used,
    asset: assets.sample,
    assigned_to: users.sample,
    purchase_date: Faker::Date.between(from: 2.years.ago, to: 6.months.ago),
    expiration_date: expiration_date,
    cost: Faker::Commerce.price(range: 100..10000.0),
    supplier: Faker::Company.name,
    notes: Faker::Lorem.paragraph
  )
end

# Create asset tracking events (100 events)
puts "Creating asset tracking events..."
rfid_assets = assets.select(&:rfid_enabled?)

100.times do
  asset = rfid_assets.sample
  next unless asset

  # Get the RFID tag and check if it's active
  rfid_tag = asset.rfid_tag
  next unless rfid_tag&.active?

  AssetTrackingEvent.create!(
    asset: asset,
    location: locations.sample,
    scanned_by: users.sample,
    event_type: ['check_in', 'check_out', 'transfer', 'inventory', 'maintenance'].sample,
    rfid_number: asset.rfid_tag.rfid_number,
    scanned_at: Faker::Time.between(from: 6.months.ago, to: Time.current)
  )
end

# Create account status logs (30 logs)
puts "Creating account status logs..."
USER_STATUSES = ['active', 'inactive', 'suspended', 'pending']
admin_user = User.find_by(email: 'admin@example.com') || users.find { |u| u.has_role?(:admin) }

raise "No admin user found!" unless admin_user

20.times do
  user = users.sample
  from_status = USER_STATUSES.sample
  to_status = (USER_STATUSES - [from_status]).sample  # Ensure different status

  AccountStatusLog.create!(
    user: user,
    status_from: from_status,
    status_to: to_status,
    changed_by: admin_user,
    reason: Faker::Lorem.sentence
  )
end

# Create audit logs
puts "Creating audit logs..."
AUDIT_ACTIONS = ['create', 'update', 'delete']
AUDITABLE_TYPES = ['Asset', 'User', 'License']

50.times do
  # Pick a random model type and get a random record
  auditable_type = AUDITABLE_TYPES.sample
  auditable = case auditable_type
              when 'Asset'
                assets.sample
              when 'User'
                users.sample
              when 'License'
                licenses.sample
              end

  AuditLog.create!(
    user: users.sample,
    action: AUDIT_ACTIONS.sample,
    auditable: auditable,
    audit_changes: {
      before: { "field" => "old_value" },
      after: { "field" => "new_value" }
    }.to_json
  )
end

puts "\nSeed completed successfully!"
puts "Created:"
puts "- #{User.count} users (including admin)"
puts "- #{Category.count} categories"
puts "- #{Location.count} locations"
puts "- #{Asset.count} assets"
puts "- #{RfidTag.count} RFID tags"
puts "- #{AssetAssignment.count} asset assignments"
puts "- #{MaintenanceSchedule.count} maintenance schedules"
puts "- #{MaintenanceRecord.count} maintenance records"
puts "- #{License.count} licenses"
puts "- #{AssetTrackingEvent.count} tracking events"
puts "- #{AccountStatusLog.count} account status logs"
puts "- #{AuditLog.count} audit logs"

# Make sure to re-enable auditing at the end
$skip_auditing = false
