module Api
  module V1
    class BaseController < ApplicationController
      before_action :doorkeeper_authorize!
      before_action :verify_scope
      
      private

      def verify_scope
        return render_unauthorized unless doorkeeper_token

        required_scopes = case request.method
        when 'GET'
          ['read']
        when 'POST', 'PUT', 'PATCH', 'DELETE'
          ['write']
        end

        unless doorkeeper_token.scopes.any? { |s| required_scopes.include?(s.to_s) }
          render json: { 
            error: 'Insufficient scope',
            required_scopes: required_scopes,
            provided_scopes: doorkeeper_token.scopes.to_a
          }, status: :forbidden
        end
      end

      def verify_admin_scope
        unless doorkeeper_token&.scopes&.include?('admin')
          render json: { 
            error: 'Admin scope required',
            provided_scopes: doorkeeper_token&.scopes&.to_a
          }, status: :forbidden
        end
      end

      def current_resource_owner
        @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      def current_application
        @current_application ||= doorkeeper_token&.application
      end

      def render_unauthorized
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def pagination_meta(object)
        {
          current_page: object.current_page,
          next_page: object.next_page,
          prev_page: object.prev_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end 