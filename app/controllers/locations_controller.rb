class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(Location).ransack(params[:q])
    @locations = @q.result
                  .includes(:assets)
                  .order(params[:sort] || 'name ASC')
                  .page(params[:page]).per(10)
  end

  def show
    authorize @location
    @assets = @location.assets.page(params[:page]).per(10)
  end

  def new
    @location = Location.new
    authorize @location
  end

  def edit
    authorize @location
  end

  def create
    @location = Location.new(location_params)
    authorize @location

    if @location.save
      redirect_to @location, notice: 'Location was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @location
    if @location.update(location_params)
      redirect_to @location, notice: 'Location was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @location
    if @location.assets.empty?
      @location.destroy
      redirect_to locations_url, notice: 'Location was successfully deleted.'
    else
      redirect_to locations_url, alert: 'Cannot delete location with associated assets.'
    end
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :address, :description, :status)
  end
end 