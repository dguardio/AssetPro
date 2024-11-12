prawn_document do |pdf|
  # Title
  pdf.text "Asset Management Dashboard Report", size: 24, style: :bold
  pdf.text "Generated on #{Date.today}", size: 12
  pdf.move_down 20

  # Overall Statistics
  pdf.text "Overall Statistics", size: 16, style: :bold
  stats_data = @stats.map { |key, value| [key.to_s.titleize, value] }
  pdf.table stats_data, width: 500
  pdf.move_down 20

  # Assets by Category
  pdf.text "Assets by Category", size: 16, style: :bold
  category_data = @assets_by_category.map { |category, count| [category, count] }
  pdf.table category_data, width: 500
  pdf.move_down 20

  # Add charts (you'll need to generate chart images and add them to the PDF)
  # This requires additional setup with Gruff or another charting library that can
  # generate images
end 