module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization
      
      before_action :identify_application_type
      before_action :verify_basic_scope
      
      rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
      rescue_from Pundit::NotAuthorizedError, with: :unauthorized_response
      
      private

      def identify_application_type
        @application_type = request.headers['X-Application-Type']
      end

      def verify_basic_scope
        required_scope = case @application_type
        when 'rfid_reader', 'mobile_app', 'erp'
          :read
        else
          :read
        end

        unless doorkeeper_token.scopes.include?(required_scope.to_s)
          render json: { 
            error: "Missing required scope: #{required_scope}",
            required_scope: required_scope,
            available_scopes: doorkeeper_token.scopes
          }, status: :forbidden
        end
      end

      def current_resource_owner
        return nil unless doorkeeper_token
        @current_resource_owner ||= if doorkeeper_token.resource_owner_id
          User.find(doorkeeper_token.resource_owner_id)
        else
          doorkeeper_token.application
        end
      end

      def not_found_response
        render json: { error: 'Resource not found' }, status: :not_found
      end

      def unauthorized_response
        render json: { error: 'Unauthorized access' }, status: :unauthorized
      end

      def verify_reader
        reader_id = request.headers['X-Reader-ID']
        @current_reader = RfidReader.find_by(reader_id: reader_id)

        unless @current_reader && @current_reader.oauth_application == current_application
          render json: {
            error: 'Invalid or unauthorized reader'
          }, status: :unauthorized
          return
        end

        unless @current_reader.active?
          render json: {
            error: 'Reader is inactive'
          }, status: :unauthorized
          return
        end

        @current_reader.touch(:last_ping_at)
      end
    end
  end
end 