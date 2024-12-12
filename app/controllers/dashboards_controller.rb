require 'csv'

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_dashboard_data
  after_action :verify_policy_scoped, except: :index

  def index
    authorize :dashboard, :index? 
    @q = Asset.ransack(search_params)
    @filtered_assets = @q.result.includes(:category, :location, :rfid_tag)
    
    @dashboard_data.merge!({
      expiring_licenses: License.expiring_soon.count,
      overdue_maintenance: MaintenanceSchedule.overdue.count,
      total_license_cost: License.sum(:cost),
      maintenance_due_this_week: MaintenanceSchedule.upcoming
                                                  .where(next_due_at: Time.current..1.week.from_now)
                                                  .count
    })
    
    @upcoming_maintenance = MaintenanceSchedule.upcoming.includes(:asset, :assigned_to).limit(5)
    @expiring_licenses = License.expiring_soon.includes(:asset).limit(5)
    
    @depreciation_data = {
      labels: 6.months.ago.to_date.upto(Date.current).map(&:to_s),
      values: @filtered_assets.map { |asset| asset.current_value }
    }
    
    respond_to do |format|
      format.html
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename=dashboard_report_#{Date.today}.xlsx"
      }
      format.csv { 
        send_data generate_csv(@filtered_assets), filename: "dashboard_report_#{Date.today}.csv" 
      }
      format.pdf {
        send_data generate_pdf(@filtered_assets), 
          filename: "dashboard_report_#{Date.today}.pdf",
          type: 'application/pdf',
          disposition: 'attachment'
      }
    end
  end

  def drilldown
    @assets = Asset.where(status: params[:status]) if params[:status]
    @assets = Asset.where(category_id: params[:category_id]) if params[:category_id]
    @assets = Asset.where(location_id: params[:location_id]) if params[:location_id]
    
    @assets = @assets.includes(:category, :location, :rfid_tag)
                    .page(params[:page])
                    .per(10)

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @assets }
    end
  end

  def timeline
    @recent_activities = AssetActivity.includes(:asset, :user, :location)
                                    .order(created_at: :desc)
                                    .limit(10)
                                    
    render partial: 'timeline'
  end  

  private

  def search_params
    params.fetch(:q, {}).permit(
      :category_id_eq,
      :location_id_eq,
      :status_eq,
      :rfid_enabled_eq,
      :s
    )
  end

  def set_dashboard_data
    # Get current values
    current_investment = Asset.sum('purchase_price * quantity')
    current_assets = Asset.count
    current_licenses = License.count
    
    # Get historical values (example using 1 month ago)
    last_month_investment = Asset.where('created_at <= ?', 1.month.ago)
                                .sum('purchase_price * quantity')
    last_week_assets = Asset.where('created_at <= ?', 1.week.ago).count

    # Calculate percentage changes
    investment_change = last_month_investment > 0 ? 
      ((current_investment - last_month_investment) / last_month_investment.to_f) * 100 : 0
    assets_change = last_week_assets > 0 ? 
      ((current_assets - last_week_assets) / last_week_assets.to_f) * 100 : 0

    @dashboard_data = {
      total_assets: current_assets,
      total_investment: current_investment,
      total_licenses: current_licenses,
      available_assets: Asset.available.count,
      in_use_assets: Asset.in_use.count,
      maintenance_assets: Asset.in_maintenance.count,
      investment_change: investment_change,
      assets_change: assets_change
    }

    @assets_by_status = Asset.group(:status).count
    @assets_by_category = Category.joins(:assets)
                                .group('categories.name')
                                .count
    @assets_by_location = Location.joins(:assets)
                                .group('locations.name')
                                .count

    @recent_activities = AssetTrackingEvent.includes(:asset, :location, :scanned_by)
                                         .order(created_at: :desc)
                                         .limit(10)
  end

  def chart_data_for(assets)
    {
      status: assets.group(:status).count,
      category: assets.joins(:category).group('categories.name').count,
      location: assets.joins(:location).group('locations.name').count
    }
  end

  def generate_csv(assets)
    CSV.generate(headers: true) do |csv|
      csv << ["Asset Management Dashboard Report - #{Date.today}"]
      csv << []
      csv << ["Asset Details"]
      csv << ["Name", "Category", "Location", "Status", "RFID Tag", "Last Updated"]
      
      assets.find_each do |asset|
        csv << [
          asset.name,
          asset.category&.name,
          asset.location&.name,
          asset.status,
          asset.rfid_tag&.rfid_number,
          asset.updated_at.strftime("%Y-%m-%d %H:%M")
        ]
      end
    end
  end

  def generate_pdf(assets)
    pdf = Prawn::Document.new do |pdf|
      pdf.text "Asset Management Dashboard Report - #{Date.today}", size: 24, style: :bold
      pdf.move_down 20

      # Asset Details
      pdf.text "Asset Details", size: 16, style: :bold
      pdf.move_down 10
      
      data = [["Name", "Category", "Location", "Status", "RFID Tag", "Last Updated"]]
      assets.find_each do |asset|
        data << [
          asset.name,
          asset.category&.name,
          asset.location&.name,
          asset.status,
          asset.rfid_tag&.rfid_number,
          asset.updated_at.strftime("%Y-%m-%d %H:%M")
        ]
      end
      
      pdf.table data do |t|
        t.header = true
        t.row_colors = ["DDDDDD", "FFFFFF"]
        t.cell_style = { size: 10 }
      end
    end

    pdf.render
  end
end 