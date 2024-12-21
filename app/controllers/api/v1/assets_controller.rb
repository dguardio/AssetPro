module Api
  module V1
    class AssetsController < BaseController
      before_action :set_asset, only: [:show, :history]
      
      def index
        @assets = policy_scope(Asset)
        @assets = params[:show_deleted] ? @assets.with_deleted : @assets
        @assets = @assets.includes(:location, :rfid_tag)
                        .order(updated_at: :desc)
        
        render json: @assets, 
               each_serializer: AssetSerializer,
               include: [:location, :rfid_tag]
      end

      def show
        render json: @asset, 
               serializer: AssetSerializer,
               include: [:location, :rfid_tag]
      end

      def history
        @events = @asset.asset_tracking_events
                       .includes(:location, :scanned_by)
                       .order(scanned_at: :desc)
        
        render json: @events, each_serializer: AssetTrackingEventSerializer
      end

      def search
        @assets = policy_scope(Asset).search(params[:q])
                      .includes(:location, :rfid_tag)
        
        render json: @assets, each_serializer: AssetSerializer
      end

      def destroy
        @asset = Asset.find(params[:id])
        authorize @asset
        
        if @asset.destroy
          head :no_content
        else
          render json: { errors: @asset.errors }, status: :unprocessable_entity
        end
      end

      def restore
        @asset = Asset.with_deleted.find(params[:id])
        authorize @asset
        
        if @asset.restore
          render json: @asset, serializer: AssetSerializer
        else
          render json: { errors: @asset.errors }, status: :unprocessable_entity
        end
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
