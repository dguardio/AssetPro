# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_11_13_163008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_status_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "changed_by_id", null: false
    t.boolean "status_from"
    t.boolean "status_to"
    t.text "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_by_id"], name: "index_account_status_logs_on_changed_by_id"
    t.index ["user_id"], name: "index_account_status_logs_on_user_id"
  end

  create_table "asset_assignments", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.bigint "user_id", null: false
    t.datetime "checked_out_at"
    t.datetime "checked_in_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "assigned_by_id", null: false
    t.index ["asset_id"], name: "index_asset_assignments_on_asset_id"
    t.index ["assigned_by_id"], name: "index_asset_assignments_on_assigned_by_id"
    t.index ["user_id"], name: "index_asset_assignments_on_user_id"
  end

  create_table "asset_tracking_events", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.bigint "location_id", null: false
    t.bigint "scanned_by_id", null: false
    t.string "event_type"
    t.string "rfid_number"
    t.datetime "scanned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_asset_tracking_events_on_asset_id"
    t.index ["location_id"], name: "index_asset_tracking_events_on_location_id"
    t.index ["rfid_number"], name: "index_asset_tracking_events_on_rfid_number"
    t.index ["scanned_by_id"], name: "index_asset_tracking_events_on_scanned_by_id"
  end

  create_table "assets", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "asset_code"
    t.string "status"
    t.date "purchase_date"
    t.decimal "purchase_price"
    t.bigint "category_id", null: false
    t.bigint "location_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rfid_enabled"
    t.datetime "last_tracked_at"
    t.decimal "depreciation_rate", precision: 5, scale: 2
    t.integer "quantity", default: 1, null: false
    t.integer "minimum_quantity", default: 1, null: false
    t.index ["asset_code"], name: "index_assets_on_asset_code", unique: true
    t.index ["category_id"], name: "index_assets_on_category_id"
    t.index ["location_id"], name: "index_assets_on_location_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "auditable_type"
    t.bigint "auditable_id"
    t.bigint "user_id"
    t.string "action"
    t.json "audit_changes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "licenses", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "license_key"
    t.integer "seats"
    t.integer "seats_used", default: 0
    t.bigint "asset_id"
    t.bigint "assigned_to_id"
    t.date "purchase_date"
    t.date "expiration_date"
    t.decimal "cost", precision: 10, scale: 2
    t.string "supplier"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_licenses_on_asset_id"
    t.index ["assigned_to_id"], name: "index_licenses_on_assigned_to_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "building"
    t.string "floor"
    t.string "room"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "maintenance_records", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.string "maintenance_type"
    t.text "description"
    t.date "scheduled_date"
    t.date "completed_date"
    t.decimal "cost"
    t.string "performed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_maintenance_records_on_asset_id"
  end

  create_table "maintenance_schedules", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "asset_id", null: false
    t.bigint "assigned_to_id"
    t.datetime "scheduled_date"
    t.datetime "completed_date"
    t.integer "status", default: 0
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_maintenance_schedules_on_asset_id"
    t.index ["assigned_to_id"], name: "index_maintenance_schedules_on_assigned_to_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.jsonb "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.string "type"
    t.json "params"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_type", "recipient_id"], name: "index_notifications_on_recipient"
  end

  create_table "rfid_tags", force: :cascade do |t|
    t.string "rfid_number"
    t.boolean "active"
    t.bigint "asset_id", null: false
    t.datetime "last_scanned_at"
    t.bigint "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_rfid_tags_on_asset_id"
    t.index ["location_id"], name: "index_rfid_tags_on_location_id"
    t.index ["rfid_number"], name: "index_rfid_tags_on_rfid_number"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "role"
    t.string "first_name"
    t.string "last_name"
    t.boolean "active", default: true
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "account_status_logs", "users"
  add_foreign_key "account_status_logs", "users", column: "changed_by_id"
  add_foreign_key "asset_assignments", "assets"
  add_foreign_key "asset_assignments", "users"
  add_foreign_key "asset_assignments", "users", column: "assigned_by_id"
  add_foreign_key "asset_tracking_events", "assets"
  add_foreign_key "asset_tracking_events", "locations"
  add_foreign_key "asset_tracking_events", "users", column: "scanned_by_id"
  add_foreign_key "assets", "categories"
  add_foreign_key "assets", "locations"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "licenses", "assets"
  add_foreign_key "licenses", "users", column: "assigned_to_id"
  add_foreign_key "maintenance_records", "assets"
  add_foreign_key "maintenance_schedules", "assets"
  add_foreign_key "maintenance_schedules", "users", column: "assigned_to_id"
  add_foreign_key "rfid_tags", "assets"
  add_foreign_key "rfid_tags", "locations"
end
