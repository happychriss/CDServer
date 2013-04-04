## Create small preview image in docstore
## called from UploadsController when a page is uploaded
## source either :scanned_jpg or :pdf

require "fileutils"
require 'drb'
require 'sidekiq'
require 'Pusher'

class ConvertWorker


  NOT_CONNECTED=0
  CONNECTED_TO_QNAS=1
  CONNECTED_TO_REMOTE=2

  include Sidekiq::Worker
  include Pusher

  sidekiq_options :retry => false

  @@processor=0
  @@status=NOT_CONNECTED

  def self.connect_to_server

    if @@processor!=0 then
      begin
        @@processor.tmp_alive?
      rescue
        @@status=NOT_CONNECTED
      end
    end
    puts "connec to server"

    if @@status==NOT_CONNECTED then

      ## try first to connect to remote host, because he can do all the work
      begin
        tmp_proc= DRbObject.new(nil, "druby://#{DRB_WORKER::REMOTE_HOST}:#{DRB_WORKER::REMOTE_PORT}") ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @@processor=tmp_proc if tmp_alive
        @@status=CONNECTED_TO_REMOTE
      rescue DRb::DRbConnError => e
        @@status=NOT_CONNECTED
        puts "not connected to remote host: #{e.message}"
      end


      ## now try to connect to qnas - because at least some work can be done locally
      if @@status==NOT_CONNECTED then

        begin
          tmp_proc= DRbObject.new(nil, "druby://#{DRB_WORKER::QNAS_HOST}:#{DRB_WORKER::QNAS_PORT}") ##
          tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
          @@processor=tmp_proc if tmp_alive
          @@status=CONNECTED_TO_QNAS

        rescue DRb::DRbConnError => e
          @@processor =0
          @@status=NOT_CONNECTED
          puts "not connected to qnass host: #{e.message}"
#        logger.info "!!!! Error RemobeWorker - couldnt connect to DRB Server: #{e.message}"
        end
      end
    end

    return @@status

  end

  def self.proc
    @@processor
  end

  def self.get_connection_status
    @@status
  end

  def self.me_alive?
  end


###############################################################################################

  def perform(page_id=nil)

    begin

      if page_id.nil? then
        pages=Page.find_all_by_status(Page::UPLOADED)
      else
        pages=[Page.find(page_id)]
      end

      raise "NoRemoteWorker" if ConvertWorker.connect_to_server==ConvertWorker::NOT_CONNECTED

      logger.info "ConvertWorker called for  #{pages.count} pages!"

      pages.each do |page|
        logger.info "Processing started for page_id #{page.id}"

        page.update_status(Page::UPLOADED_PROCESSING)

        push_status_update ## send status-update to application main page via private_pub gem, fayes,

        logger.info "Processing file remote: #{page.id}"

        scanned_jpg=File.read(page.tmp_docstore_path)

        ### REMOTE CALL via DRB - the server can run on any server: ruby DRbProcessor.rb run

        result_jpg, result_sjpg, result_pdf, result_txt=@@processor.convert(scanned_jpg, page.format)

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
      Log.write_error('ConvertWorker', 'Converting' + '->' +e.message)
      push_status_update ## send status-update to application main page via private_pub gem, fayes,
      raise
    end
  end


end