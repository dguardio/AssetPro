module Admin
  class OauthApplicationsController < ApplicationController
    before_action :set_application, only: [:show, :edit, :update, :destroy]

    def index
      @applications = policy_scope(Doorkeeper::Application).all
    end

    def show
      authorize @application
      @readers = @application.rfid_readers.order(last_ping_at: :desc)
      @recent_scans = AssetTrackingEvent.where(oauth_application: @application)
                               .includes(:asset)
                               .order(created_at: :desc)
                               .limit(10)
    end

    def new
      @application = Doorkeeper::Application.new
      authorize @application
    end

    def create
      @application = Doorkeeper::Application.new(application_params)
      authorize @application
      
      if @application.save
        redirect_to admin_oauth_applications_path, 
          notice: 'Reader application created successfully.'
      else
        render :new
      end
    end

    def edit
      authorize @application
    end

    def update
      authorize @application
      if @application.update(application_params)
        redirect_to admin_oauth_applications_path, 
          notice: 'Reader application updated successfully.'
      else
        render :edit
      end
    end

    private

    def set_application
      @application = Doorkeeper::Application.find(params[:id])
    end

    def application_params
      params.require(:doorkeeper_application).permit(
        :name, 
        :organization_name,
        :sub_organization_name,
        :app_type,
        :scopes,
        :confidential,
        :redirect_uri
      )
    end
  end
end 