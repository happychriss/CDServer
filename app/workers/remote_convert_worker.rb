## Create small preview image in docstore
## called from UploadsController when a page is uploaded

require "fileutils"
require 'drb'
require 'sidekiq'
require 'Pusher'

class RemoteConvertWorker


  NOT_CONNECTED=0
  CONNECTED_TO_QNAS=1
  CONNECTED_TO_REMOTE=2

  include Sidekiq::Worker
  include Pusher

  sidekiq_options :retry => false

  ###############################################################################################
  # allows to start converter locally not via sidekiq if DRB_SIDEKICK is set in initializer for drb


  def self.my_perform(page_ids)
    if DRB_SIDEKICK==true then
      RemoteConvertWorker.perform_async(page_ids)
    else
      rm=RemoteConvertWorker.new #direct calling
      rm.perform(page_ids) #direct calling
      end

  end

###############################################################################################
# calling remote worker to create small images and PDF OCR. expecting an array of page_ids

  def perform(page_ids)

    begin

      DaemonConverter.instance.connected=true ##this is used in context of push_status_update

      logger.info "RemoteConvertWorker called for  #{page_ids.count} pages!"

      page_ids.each do |page_id|

        page=Page.find(page_id)

        logger.info "Processing started for page_id #{page.id}"

        page.update_status_preview(Page::UPLOADED_PROCESSING)

        push_status_update ## send status-update to application main page via private_pub gem, fayes,

        logger.info "Processing scanned file remote: #{page.id} with path: #{page.path(:org)} and mime type #{page.short_mime_type}"

        scanned_jpg=File.read(page.path(:org))

        ### REMOTE CALL via DRB - the server can run on any server: distributed ruby

        logger.info "start remote call to DRB Converter: #{DaemonConverter}"

        result_jpg, result_sjpg, result_orginal, result_txt, result_status=DaemonConverter.instance.processor.run_conversion(scanned_jpg, page.short_mime_type)

        logger.info "complete remote call to DRB"

        if result_status !='OK' then
          Log.write_error('RemoteConvertWorker', "Remote Converting: #{result_status}")
          push_status_update ## send status-update to application main page via private_pub gem, fayes,
          return
        end

        page.update_conversion(result_jpg, result_sjpg, result_orginal, result_txt)

        logger.info "Processing file remote: page_id #{page.id}  completed"

        push_status_update ## send status-update to application main page via private_pub gem, fayes,
        push_converted_page(page)

      end

    rescue Exception => e
      PrivatePub.publish_to "/status", :chat_message => "Hello, world!"
      Log.write_error('RemoteConvertWorker', 'Converting' + '->' +e.message)
      push_status_update ## send status-update to application main page via private_pub gem, fayes,
      raise
    end
  end


##++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end