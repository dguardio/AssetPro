class MakeScannedByOptionalInAssetTrackingEvents < ActiveRecord::Migration[7.0]
  def change
    change_column_null :asset_tracking_events, :scanned_by_id, true
  end
end