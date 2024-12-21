module Api
  module V1
    class AssetAssignmentsController < BaseController
      before_action :set_asset_assignment, only: [:show, :update, :check_out, :check_in, :destroy, :restore]

      def index
        @assignments = policy_scope(AssetAssignment)
        @assignments = params[:show_deleted] ? @assignments.with_deleted : @assignments
        @assignments = @assignments.includes(:asset, :user, :assigned_by)
                                 .order(created_at: :desc)
                                 .page(params[:page])

        render json: {
          data: ActiveModel::SerializableResource.new(@assignments, each_serializer: AssetAssignmentSerializer),
          meta: pagination_meta(@assignments)
        }
      end

      def show
        authorize @asset_assignment
        render json: @asset_assignment, serializer: AssetAssignmentSerializer
      end

      def create
        @asset_assignment = AssetAssignment.new(asset_assignment_params)
        @asset_assignment.assigned_by = current_resource_owner
        
        authorize @asset_assignment

        if @asset_assignment.save
          render json: @asset_assignment, serializer: AssetAssignmentSerializer, status: :created
        else
          render json: { errors: @asset_assignment.errors }, status: :unprocessable_entity
        end
      end

      def update
        authorize @asset_assignment
        if @asset_assignment.update(asset_assignment_params)
          render json: @asset_assignment, serializer: AssetAssignmentSerializer
        else
          render json: { errors: @asset_assignment.errors }, status: :unprocessable_entity
        end
      end

      def check_out
        authorize @asset_assignment
        @asset_assignment.checked_out_at = Time.current
        
        if @asset_assignment.save
          render json: @asset_assignment, serializer: AssetAssignmentSerializer
        else
          render json: { errors: @asset_assignment.errors }, status: :unprocessable_entity
        end
      end

      def check_in
        authorize @asset_assignment
        @asset_assignment.checked_in_at = Time.current
        
        if @asset_assignment.save
          render json: @asset_assignment, serializer: AssetAssignmentSerializer
        else
          render json: { errors: @asset_assignment.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @asset_assignment
        
        if @asset_assignment.destroy
          head :no_content
        else
          render json: { errors: @asset_assignment.errors }, status: :unprocessable_entity
        end
      end

      def restore
        authorize @asset_assignment
        
        if @asset_assignment.restore
          render json: @asset_assignment, serializer: AssetAssignmentSerializer
        else
          render json: { errors: @asset_assignment.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_asset_assignment
        @asset_assignment = AssetAssignment.with_deleted.find(params[:id])
        authorize @asset_assignment
      end

      def asset_assignment_params
        params.require(:asset_assignment).permit(
          :asset_id,
          :user_id,
          :checked_out_at,
          :checked_in_at,
          :notes,
          :assigned_by_id
        )
      end
    end
  end
end
