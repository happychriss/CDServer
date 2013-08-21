## Create small preview image in docstore
## called from UploadsController when a page is uploaded
## source either :scanned_jpg or :pdf

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

  @@processor=0
  @@status=NOT_CONNECTED


def self.connected?
  not self.connect_to_server==RemoteConvertWorker::NOT_CONNECTED
end


###############################################################################################
# calling remote worker to create small images and PDF OCR. expecting an array of page_ids

  def perform(page_ids)

    begin

     logger.info "RemoteConvertWorker called for  #{page_ids.count} pages!"

      pages_ids.each do |page_id|

        page=Page.find(page_id)

        logger.info "Processing started for page_id #{page.id}"

        page.update_status(Page::UPLOADED_PROCESSING)

        push_status_update ## send status-update to application main page via private_pub gem, fayes,

        logger.info "Processing file remote: #{page.id}"

        scanned_jpg=File.read(page.path(:orginal))

        ### REMOTE CALL via DRB - the server can run on any server: ruby DRbProcessor.rb run

        result_jpg, result_sjpg, result_pdf, result_txt=@@processor.convert(scanned_jpg, page.source)

        page.save_file(result_sjpg, :s_jpg)
        page.save_file(result_jpg, :jpg)
        page.save_file(result_pdf, :pdf)
        page.add_content(result_txt)

        page.update_status(Page::UPLOADED_PROCESSED)

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

  private

  def self.proc
    @@processor
  end

  def self.get_connection_status
    @@status
  end

  def self.me_alive?
  end


  def self.connect_to_server

    if @@processor!=0 then
      begin
        @@processor.tmp_alive?
      rescue
        @@status=NOT_CONNECTED
      end
    end
    puts "connect to server"

    if @@status==NOT_CONNECTED then

      ## try first to connect to remote host, because he can do all the work
      begin
        tmp_proc= DRbObject.new(nil, "druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port']}") ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @@processor=tmp_proc if tmp_alive
        @@status=CONNECTED_TO_REMOTE
      rescue DRb::DRbConnError => e
        @@status=NOT_CONNECTED
        @@processor =0
        puts "not connected to remote host: #{e.message}"
      end

    end

    return @@status

  end

end