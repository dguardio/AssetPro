module Api
  module V1
    class RfidTagsController < BaseController
      before_action :set_rfid_tag, only: [:show, :update, :destroy, :restore]

      def index
        @rfid_tags = policy_scope(RfidTag)
        @rfid_tags = params[:show_deleted] ? @rfid_tags.with_deleted : @rfid_tags
        @rfid_tags = @rfid_tags.includes(asset: :location)
                              .order(updated_at: :desc)
        
        render json: @rfid_tags, 
               each_serializer: RfidTagSerializer,
               include: ['asset', 'asset.location']
      end

      def show
        authorize @rfid_tag
        # If the rfid_tag is not found, return a 404
        # If the rfid_tag is found, return a 200
        if @rfid_tag.nil?
          render json: { error: "Rfid tag not found" }, status: :not_found
        else
          render json: @rfid_tag, serializer: RfidTagSerializer
        end
      end

      def destroy
        authorize @rfid_tag
        
        if @rfid_tag.destroy
          head :no_content
        else
          render json: { errors: @rfid_tag.errors }, status: :unprocessable_entity
        end
      end

      def restore
        authorize @rfid_tag
        
        if @rfid_tag.restore
          render json: @rfid_tag, serializer: RfidTagSerializer
        else
          render json: { errors: @rfid_tag.errors }, status: :unprocessable_entity
        end
      end

      private

      def set_rfid_tag
        @rfid_tag = RfidTag.with_deleted.find(params[:id])
        authorize @rfid_tag
      end
    end
  end
end 