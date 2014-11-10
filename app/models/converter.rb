require 'ServiceConnector'

class Converter

  extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Converter"
  end


  def self.run_conversion(page_ids)

    page_ids.each do |page_id|

      page=Page.find(page_id)

      page.update_status_preview(Page::UPLOADED_PROCESSING)

      puts "Start remote call: Processing scanned file remote: #{page.id} with path: #{page.path(:org)} and mime type #{page.short_mime_type} and Source: #{page.source.to_s}"

      scanned_jpg=File.read(page.path(:org))

      ### REMOTE CALL via DRB - the server can run on any server: distributed ruby

      Converter.get_drb.run_conversion(scanned_jpg, page.short_mime_type, page.source, page.id)

      puts "complete remote call to DRB"

    end

  end
end