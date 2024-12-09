class AddAssetAssignmentToAssetTrackingEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :asset_tracking_events, :asset_assignment, null: true, foreign_key: true
  end
end
