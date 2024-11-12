class RfidTagsController < ApplicationController
  before_action :set_asset
  before_action :authorize_asset

  def new
    @rfid_tag = @asset.build_rfid_tag
  end

  def create
    @rfid_tag = @asset.build_rfid_tag(rfid_tag_params)
    @rfid_tag.last_known_location = @asset.location

    if @asset.assign_rfid_tag!(@rfid_tag.rfid_number)
      redirect_to @asset, notice: 'RFID tag was successfully assigned.'
    else
      render :new
    end
  end

  private

  def set_asset
    @asset = Asset.find(params[:asset_id])
  end

  def authorize_asset
    authorize @asset, :update?
  end

  def rfid_tag_params
    params.require(:rfid_tag).permit(:rfid_number)
  end
end 