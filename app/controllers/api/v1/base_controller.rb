class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: 'Not authorized' }, status: :forbidden
  end
end 