module Api
  module V1
    class AssetRequestsController < BaseController
      before_action :set_asset_request, only: [:show, :update, :approve, :reject]

      def index
        @requests = policy_scope(AssetRequest)
        @requests = params[:show_deleted] ? @requests.with_deleted : @requests
        @requests = @requests.includes(:asset, :user, :reviewed_by)
                           .order(created_at: :desc)
                           .page(params[:page])

        render json: {
          data: ActiveModel::SerializableResource.new(@requests, each_serializer: AssetRequestSerializer),
          meta: pagination_meta(@requests)
        }
      end

      def show
        authorize @asset_request
        render json: @asset_request, serializer: AssetRequestSerializer
      end

      def create
        @asset_request = current_resource_owner.asset_requests.build(asset_request_params)
        authorize @asset_request

        if @asset_request.save
          render json: @asset_request, status: :created, serializer: AssetRequestSerializer
        else
          render json: { errors: @asset_request.errors }, status: :unprocessable_entity
        end
      end

      def approve
        authorize @asset_request
        @asset_request.reviewed_by = current_resource_owner
        @asset_request.reviewed_at = Time.current

        if @asset_request.update(status: :approved)
          AssetAssignment.create!(
            asset: @asset_request.asset,
            user: @asset_request.user,
            assigned_by: current_resource_owner,
            checked_out_at: @asset_request.requested_from,
            notes: "Auto-assigned from request ##{@asset_request.id}"
          )
          render json: @asset_request, serializer: AssetRequestSerializer
        else
          render json: { errors: @asset_request.errors }, status: :unprocessable_entity
        end
      end

      def reject
        authorize @asset_request
        @asset_request.reviewed_by = current_resource_owner
        @asset_request.reviewed_at = Time.current

        if @asset_request.update(status: :rejected, rejection_reason: params[:rejection_reason])
          render json: @asset_request, serializer: AssetRequestSerializer
        else
          render json: { errors: @asset_request.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_asset_request
        @asset_request = AssetRequest.find(params[:id])
      end

      def asset_request_params
        params.require(:asset_request).permit(
          :asset_id, :purpose, :requested_from, :requested_until
        )
      end
    end
  end
end 