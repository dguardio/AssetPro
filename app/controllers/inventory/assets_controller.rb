module Inventory
  class AssetsController < ApplicationController
    include AssetParameters
    
    before_action :authenticate_user!
    before_action :set_asset, only: [:show, :edit, :update, :destroy, :restore]
    after_action :verify_authorized, except: :index
    after_action :verify_policy_scoped, only: :index
  
    def index
      @q = policy_scope(Asset)
      @q = params[:show_deleted] ? @q.only_deleted : @q.without_deleted
      @q = @q.ransack(params[:q])
      @assets = @q.result.includes(:category, :location)
                  .order(params[:sort] || 'created_at DESC')

      respond_to do |format|
        format.html do
          @assets = @assets.page(params[:page]).per(10)
        end
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
  
    def show
      authorize @asset
      @depreciation = @asset.current_value
      @maintenance_due = @asset.next_maintenance 
      @warranty_status = @asset.warranty_status
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
      if @asset.destroy
        redirect_to inventory_assets_url, notice: 'Asset was successfully archived.'
      else
        redirect_to inventory_assets_url, alert: 'Failed to archive asset.'
      end
    end
  
    def restore
      @asset = Asset.only_deleted.find(params[:id])
      authorize @asset
      
      if @asset.recover
        redirect_to inventory_assets_url, notice: 'Asset was successfully restored.'
      else
        redirect_to inventory_assets_url, alert: 'Failed to restore asset.'
      end
    end
  
    def import
      authorize([:inventory, Asset], :import?)
      
      if params[:file].present?
        begin
          result = Asset.import(params[:file])
          if result[:success]
            redirect_to inventory_assets_path, 
              notice: result[:message],
              alert: result[:skipped_assets].any? ? "Some assets were skipped during import." : nil
          else
            redirect_to inventory_assets_path, alert: "Import failed: #{result[:message]}"
          end
        rescue StandardError => e
          redirect_to inventory_assets_path, alert: "Import failed: #{e.message}"
        end
      else
        redirect_to inventory_assets_path, alert: 'Please select a file to import.'
      end
    end
  
    def download_template
      authorize([:inventory, Asset], :download_template?)
      headers = [
        'name',                    # Required
        'asset_code',              # Required
        'category',                # Required - name instead of ID
        'location',                # Required - name instead of ID
        'status',                  # Optional
        'description',             # Optional
        'purchase_date',           # Optional
        'purchase_price',          # Optional
        'quantity',                # Optional
        'minimum_quantity',        # Optional
        'useful_life_years',       # Optional
        'salvage_value',           # Optional
        'warranty_expiry_date',    # Optional
        'maintenance_cost_yearly', # Optional
        'insurance_value',         # Optional
        'depreciation_rate',       # Optional
        'rfid_enabled'            # Optional
      ]
      
      example_row = [
        'Dell Laptop XPS 15',      # name
        'AST-001',                 # asset_code
        'Laptops',                 # category name
        'Main Office',             # location name
        'available',               # status
        'High-performance laptop', # description
        '2024-03-20',             # purchase_date
        '1299.99',                # purchase_price
        '1',                      # quantity
        '1',                      # minimum_quantity
        '5',                      # useful_life_years
        '299.99',                 # salvage_value
        '2026-03-20',            # warranty_expiry_date
        '99.99',                 # maintenance_cost_yearly
        '1500.00',               # insurance_value
        '20',                    # depreciation_rate
        'false'                  # rfid_enabled
      ]
      
      csv_data = CSV.generate(headers: true) do |csv|
        csv << headers
        csv << example_row
      end

      respond_to do |format|
        format.csv do
          send_data csv_data, 
                    filename: "assets_import_template.csv", 
                    type: 'text/csv'
        end
        format.xlsx do
          # Handle Excel template
          workbook = WriteXLSX.new
          worksheet = workbook.add_worksheet
          
          # Add headers and example row
          worksheet.write_row(0, 0, headers)
          worksheet.write_row(1, 0, example_row)
          
          send_data workbook.string,
                    filename: "assets_import_template.xlsx",
                    type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        end
      end
    end    

  
    private
  
    def set_asset
      @asset = params[:id].present? ? Asset.with_deleted.find(params[:id]) : Asset.new
    end
  end 
end 