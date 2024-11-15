module Importable
  extend ActiveSupport::Concern
  
  module ClassMethods
    def import(file)
      require 'csv'
      require 'roo'
      
      spreadsheet = open_spreadsheet(file)
      header = spreadsheet.row(1)
      
      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        record = find_by_id(row["id"]) || new
        record.attributes = row.to_hash.slice(*column_names)
        record.save!
      end
    end
    
    def to_csv
      require 'csv'
      
      CSV.generate(headers: true) do |csv|
        csv << column_names
        all.each do |record|
          csv << record.attributes.values_at(*column_names)
        end
      end
    end
    
    private
    
    def open_spreadsheet(file)
      case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
      else raise "Unknown file type: #{file.original_filename}"
      end
    end
  end
end 