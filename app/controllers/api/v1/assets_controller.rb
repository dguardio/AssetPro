class Api::V1::AssetsController < Api::V1::BaseController
  def index
    @assets = Asset.accessible_by(current_ability)
    render json: @assets
  end

  def show
    render json: @asset
  end

  def create
    @asset = Asset.new(asset_params)
    if @asset.save
      render json: @asset, status: :created
    else
      render json: { errors: @asset.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @asset.update(asset_params)
      render json: @asset
    else
      render json: { errors: @asset.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @asset.destroy
    head :no_content
  end

  private

  def asset_params
    params.require(:asset).permit(
      :name, :description, :asset_code, :status,
      :purchase_date, :purchase_price, :category_id, :location_id
    )
  end
end
