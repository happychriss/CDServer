## Create small preview image in docstore
## Called when remote convert worker is not available

require "fileutils"
require 'sidekiq'
require 'Pusher'

class LocalConvertWorker
  include Sidekiq::Worker
  include Pusher

  sidekiq_options :retry => false

  def perform(page_id)

    page=Page.find(page_id)

    logger.info "LocalConvertWorker called for  #{page.path(:original)} with mime_type #{page.mime_type}!"

    if ["application/pdf","image/jpeg"].include? page.mime_type then
      logger.info "Converting page"
      res=%x[convert '#{page.path(:original)}'[0] -resize 350x490 -quality 40% jpg:'#{page.path(:s_jpg)}']

      logger.info "Converted page with result:#{res}"
      page.update_status_preview(Page::UPLOADED_NOT_PROCESSED,true)
    else
      logger.info "No Converting - not supported format"
      page.update_status_preview(Page::UPLOADED_NOT_PROCESSED,false)
    end

    push_status_update ## send status-update to application main page via private_pub gem, fayes,
    push_converted_page(page)

  end
end