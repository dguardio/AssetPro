module Api
  module V1
    class RfidReadersController < BaseController
      before_action :doorkeeper_authorize!
      before_action :set_reader, only: [:show, :update]
      before_action :verify_admin, except: [:show, :ping]

      def show
        authorize @reader
        render json: @reader, serializer: RfidReaderSerializer
      end

      def update
        authorize @reader
        
        if @reader.update(reader_params)
          render json: @reader, serializer: RfidReaderSerializer
        else
          render json: { errors: @reader.errors }, 
                 status: :unprocessable_entity
        end
      end

      # Handle reader heartbeat/status updates
      def ping
        @reader = RfidReader.find_by(
          oauth_application_id: current_application.id
        )
        
        if @reader.nil?
          render json: { error: 'Reader not found' }, status: :not_found
          return
        end

        @reader.update!(
          last_ping_at: Time.current,
          active: true
        )

        render json: {
          status: 'ok',
          server_time: Time.current,
          reader: {
            reader_id: @reader.reader_id,
            name: @reader.name,
            position: @reader.position,
            active: @reader.active,
            last_ping_at: @reader.last_ping_at
          }
        }
      rescue => e
        render json: { 
          error: 'Failed to update reader status',
          details: e.message 
        }, status: :unprocessable_entity
      end

      private

      def set_reader
        @reader = RfidReader.find(params[:id])
      end

      def reader_params
        params.require(:rfid_reader).permit(
          :reader_id,
          :name,
          :position,
          :active
        )
      end

      def verify_admin
        unless current_resource_owner.admin?
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end
    end
  end
end 