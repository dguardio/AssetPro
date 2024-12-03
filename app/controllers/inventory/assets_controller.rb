module Inventory
  class AssetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_asset, only: [:show, :edit, :update, :destroy]
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
  
    def index
      @q = policy_scope(Asset).ransack(params[:q])
      @assets = @q.result.includes(:category, :location)
                  .order(params[:sort] || 'created_at DESC')
                  .page(params[:page]).per(10)
    end
  
    def show
      authorize @asset
    end
  
    def new
      @asset = Asset.new
      authorize @asset
    end
  
    def edit
      authorize @asset
    end
  
    def create
      @asset = Asset.new(asset_params)
      authorize @asset
  
      if @asset.save
        redirect_to inventory_asset_path(@asset), notice: 'Asset was successfully created.'
      else
        render :new
      end
    end
  
    def update
      authorize @asset
      if @asset.update(asset_params)
        redirect_to inventory_asset_path(@asset), notice: 'Asset was successfully updated.'
      else
        render :edit
      end
    end
  
    def destroy
      authorize @asset
      @asset.destroy
      redirect_to inventory_assets_url, notice: 'Asset was successfully deleted.'
    end
  
    def import
      authorize([:inventory, Asset], :import?)
      
      if params[:file].present?
        result = Asset.import(params[:file])
        if result.successful?
          redirect_to inventory_assets_path, notice: 'Assets were successfully imported.'
        else
          redirect_to inventory_assets_path, alert: "Import failed: #{result.errors.join(', ')}"
        end
      else
        redirect_to inventory_assets_path, alert: 'Please select a file to import.'
      end
    end
  
    def export
      authorize([:inventory, Asset], :export?)
      
      @assets = policy_scope(Asset).includes(:location, :category)
      
      respond_to do |format|
        format.csv do
          send_data @assets.to_csv, 
                    filename: "assets-#{Date.current}.csv",
                    type: 'text/csv'
        end
        format.xlsx do
          response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          response.headers['Content-Disposition'] = "attachment; filename=assets-#{Date.current}.xlsx"
          render xlsx: 'export', template: 'inventory/assets/export'
        end
      end
    end

    def download_template
      authorize([:inventory, Asset], :download_template?)
      headers = [
        'name', 'asset_code', 'category_id', 'location_id', 
        'status', 'purchase_date', 'purchase_price', 
        'description', 'quantity', 'minimum_quantity'
      ]
      
      example_row = [
        'Dell Laptop XPS 15',    # name
        'AST-001',               # asset_code
        '1',                     # category_id
        '1',                     # location_id
        'available',             # status
        '2024-03-20',           # purchase_date
        '1299.99',              # purchase_price
        'High-performance laptop', # description
        '1',                     # quantity
        '1'                      # minimum_quantity
      ]
      
      csv_data = CSV.generate(headers: true) do |csv|
        csv << headers
        csv << example_row
      end
    
      send_data csv_data, 
                filename: "assets_import_template.csv", 
                type: 'text/csv'
    end    
  
    private
  
    def set_asset
      @asset = Asset.find(params[:id])
    end
  
    def asset_params
      params.require(:asset).permit(:name, :description, :category_id, :location_id, :status)
    end
  end 
end 