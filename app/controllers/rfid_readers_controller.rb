class RfidReadersController < ApplicationController
  before_action :set_reader, only: [:show, :edit, :update, :destroy, :toggle_active]

  def index
    @readers = policy_scope(RfidReader).includes(:oauth_application).order(last_ping_at: :desc)
    authorize @readers
  end

  def show
    authorize @reader
    @recent_scans = @reader.asset_tracking_events.includes(:asset)
                          .order(created_at: :desc).limit(10)
  end

  def new
    @reader = RfidReader.new
    authorize @reader
  end

  def edit
    authorize @reader
  end

  def create
    @reader = RfidReader.new(reader_params)
    authorize @reader
    if @reader.save
      redirect_to rfid_readers_path, notice: 'RFID Reader was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @reader
    if @reader.update(reader_params)
      redirect_to rfid_readers_path, notice: 'RFID Reader was successfully updated.'
    else
      render :edit
    end
  end

  def toggle_active
    authorize @reader
    @reader.toggle!(:active)
    redirect_to rfid_readers_path, notice: "Reader #{@reader.active? ? 'activated' : 'deactivated'}"
  end

  private

  def set_reader
    #Set reader if soft deleted or not
    @reader = params[:id].present? ? RfidReader.with_deleted.find(params[:id]) : RfidReader.new
  end

  def reader_params
    params.require(:rfid_reader).permit(:name, :reader_id, :position, :active, :oauth_application_id)
  end
end 