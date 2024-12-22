module Api
  module V1
    class AssetsController < BaseController
      include AssetParameters

      before_action :set_asset, only: [:show, :update, :destroy, :history, :restore]

      def index
        @assets = policy_scope(Asset)
        @assets = params[:show_deleted] ? @assets.with_deleted : @assets
        @assets = @assets.includes(:location, :category, :rfid_tag)
                        .order(updated_at: :desc)
                        .page(params[:page]).per(25)

        render json: {
          assets: ActiveModel::SerializableResource.new(@assets, each_serializer: AssetSerializer),
          meta: {
            total_count: @assets.total_count,
            current_page: @assets.current_page,
            total_pages: @assets.total_pages,
            per_page: @assets.limit_value
          }
        }
      end

      def show
        render json: @asset, 
               serializer: AssetSerializer, 
               include: ['location', 'category', 'rfid_tag'],
               meta: {
                 depreciation: @asset.calculate_depreciation,
                 maintenance_due: @asset.maintenance_due?,
                 warranty_status: @asset.warranty_status
               }
      end

      def create
        @asset = Asset.new(asset_params)
        authorize @asset
        if @asset.save
          render json: @asset, status: :created, serializer: AssetSerializer, include: ['location', 'category', 'rfid_tag']
        else
          render json: { errors: @asset.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @asset
        
        if @asset.update(asset_params)
          render json: @asset, 
                 status: :ok,
                 serializer: AssetSerializer,
                 include: ['location', 'category']
        else
          render json: { errors: @asset.errors }, status: :unprocessable_entity
        end
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
        @asset = Asset.with_deleted.includes(:location, :category, :rfid_tag)
                     .find(params[:id])
        authorize @asset
      end
    end
  end
end
