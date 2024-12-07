class RfidTagsController < ApplicationController
  before_action :set_rfid_tag, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(RfidTag).ransack(params[:q])
    @rfid_tags = @q.result.includes(asset: :location)
    .order(params[:sort] || 'created_at DESC')
    .page(params[:page]).per(10)
  end

  def show
    authorize @rfid_tag
  end

  def new
    @rfid_tag = RfidTag.new
    authorize @rfid_tag
  end

  def edit
    authorize @rfid_tag
  end

  def create
    @rfid_tag = RfidTag.new(rfid_tag_params)
    authorize @rfid_tag

    if @rfid_tag.save
      redirect_to @rfid_tag, notice: 'RFID tag was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @rfid_tag
    if @rfid_tag.update(rfid_tag_params)
      redirect_to @rfid_tag, notice: 'RFID tag was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @rfid_tag
    @rfid_tag.destroy
    redirect_to rfid_tags_url, notice: 'RFID tag was successfully deleted.'
  end

  private

  def set_rfid_tag
    @rfid_tag = RfidTag.find(params[:id])
  end

  def rfid_tag_params
    params.require(:rfid_tag).permit(:rfid_number, :asset_id, :active, :last_scanned_at)
  end
end 