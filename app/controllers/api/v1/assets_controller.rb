module Api
  module V1
    class AssetsController < BaseController
      before_action :doorkeeper_authorize!
      before_action :set_asset, only: [:show, :history]
      
      def index
        @assets = policy_scope(Asset)
                 .includes(:location, :rfid_tag)
                 .order(updated_at: :desc)
        
        render json: @assets, each_serializer: AssetSerializer
      end

      def show
        render json: @asset, serializer: AssetSerializer
      end

      def history
        @events = @asset.asset_tracking_events
                       .includes(:location, :scanned_by)
                       .order(scanned_at: :desc)
        
        render json: @events, each_serializer: AssetTrackingEventSerializer
      end

      def search
        @assets = Asset.search(params[:q])
                      .includes(:location, :rfid_tag)
        
        render json: @assets, each_serializer: AssetSerializer
      end

      private

      def set_asset
        @asset = Asset.includes(:location, :rfid_tag, :asset_tracking_events)
                     .find(params[:id])
        authorize @asset
      end
    end
  end
end
