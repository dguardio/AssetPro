module Api
  module V1
    class UpdatesController < BaseController
      def check_version
        updates_path = Rails.public_path.join('updates')
        
        if Dir.exist?(updates_path)
          # Get all .bin files and extract version numbers
          bin_files = Dir.glob("#{updates_path}/*.bin")
          
          if bin_files.any?
            # Extract version from filename and sort to get latest
            latest_file = bin_files.max_by do |file|
              # Assuming filename format: update_1.2.3.bin
              File.basename(file, '.bin').split('_').last
            end
            
            version = File.basename(latest_file, '.bin').split('_').last
            file_name = File.basename(latest_file)
            
            render json: {
              version: version,
              url: "#{request.base_url}/updates/#{file_name}"
            }
          else
            render json: { error: 'No updates available' }, status: :not_found
          end
        else
          render json: { error: 'Updates directory not found' }, status: :not_found
        end
      end
    end
  end
end 