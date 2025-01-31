class LicensesController < ApplicationController
  before_action :set_license, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(License).ransack(params[:q])
    @licenses = @q.result.includes(:asset).page(params[:page])
  end

  def show
    authorize @license
  end

  def new
    @license = License.new
    authorize @license
  end

  def edit
    authorize @license
  end

  def create
    @license = License.new(license_params)
    authorize @license

    if @license.save
      redirect_to @license, notice: 'License was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @license
    if @license.update(license_params)
      check_license_thresholds
      redirect_to @license, notice: 'License updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @license
    @license.destroy
    redirect_to licenses_url, notice: 'License was successfully deleted.'
  end

  private

  def set_license
    #Set license if soft deleted or not
    @license = params[:id].present? ? License.with_deleted.find(params[:id]) : License.new
  end

  def license_params
    params.require(:license).permit(:name, :license_key, :seats, :expiration_date, :supplier, :cost, :notes, :asset_id)
  end

  def check_license_thresholds
    # Check expiration
    if @license.expires_soon?
      LicenseExpiringNotification.with(license: @license).deliver_later(@license.assigned_to)
    end

    # Check seats usage
    if @license.seats_used_percentage >= 80
      LicenseNotifier.with(license: @license).seats_threshold_reached
    end
  end
end 