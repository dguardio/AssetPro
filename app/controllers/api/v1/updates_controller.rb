module Api
  module V1
    class UpdatesController < BaseController
      skip_before_action :doorkeeper_authorize!
      skip_before_action :verify_scope, only: [:check_version]
      # skip_before_action :verify_authenticity_token, only: [:check_version]

      # Check version for Hardware updates
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

      # Check version for Mobile updates
      def check_mobile_version
        # TODO: Implement mobile version check
        # Check the updates folder for a single .apk file
        # Get the version from the file name
        # Return the version and the url to the apk file
        updates_path = Rails.public_path.join('updates')
        # There should only be one apk file in the updates folder
        apk_files = Dir.glob("#{updates_path}/*.apk")
        if apk_files.any?
          version = File.basename(apk_files.first, '.apk').split('_').last
          file_name = File.basename(apk_files.first)
          render json: {
            version_code: version,
            version_name: version,
            apk_url: "#{request.base_url}/updates/#{file_name}"
          }
        end
      end
    end
  end
end 