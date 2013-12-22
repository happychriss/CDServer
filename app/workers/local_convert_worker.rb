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

    DaemonConverter.instance.connected=false ##this is used in context of push_status_update

    page=Page.find(page_id)

    logger.info "LocalConvertWorker called for  #{page.path(:org)} with mime_type #{page.mime_type}!"

    if ["application/pdf","image/jpeg"].include? page.mime_type then
      logger.info "Converting page"
      res=%x[convert '#{page.path(:org)}'[0] -resize 350x490 -quality 40% jpg:'#{page.path(:s_jpg)}']

      logger.info "Converted page with result:#{res}"
      page.update_status_preview(Page::UPLOADED_NOT_PROCESSED,Page::PAGE_PREVIEW)
    else
      logger.info "No Converting - not supported format"
      page.update_status_preview(Page::UPLOADED_NOT_PROCESSED,Page::PAGE_NO_PREVIEW)
    end

    push_status_update ## send status-update to application main page via private_pub gem, fayes,
    push_converted_page(page)

  end
end