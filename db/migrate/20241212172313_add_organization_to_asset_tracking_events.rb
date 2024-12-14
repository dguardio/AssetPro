class AddOrganizationToAssetTrackingEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :asset_tracking_events, :oauth_application, foreign_key: { to_table: :oauth_applications }
    add_column :asset_tracking_events, :organization_id, :bigint
    add_column :asset_tracking_events, :sub_organization_id, :bigint
    add_column :asset_tracking_events, :organization_name, :string
    add_column :asset_tracking_events, :sub_organization_name, :string
    
    add_index :asset_tracking_events, :organization_id
    add_index :asset_tracking_events, :sub_organization_id
  end
end
