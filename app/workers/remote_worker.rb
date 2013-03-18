## Create small preview image in docstore
## called from UploadsController when a page is uploaded
## source either :scanned_jpg or :pdf

require "fileutils"
require 'drb'
require 'sidekiq'

class RemoteWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  @@processor=0

  def self.connect_to_server
    if @@processor=0 then
      begin
        tmp_proc= DRbObject.new(nil, "druby://#{DRB_WORKER::HOST}:8999") ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @@processor=tmp_proc if tmp_alive
      rescue DRb::DRbConnError => e
        @@processor =0
#        logger.info "!!!! Error RemobeWorker - couldnt connect to DRB Server: #{e.message}"
      end
    end

    return @@processor!=0

  end

  def self.proc
    @@processor
  end

  def self.active?
    @@processor!=0
  end
###############################################################################################

  def perform(page_id=nil)

    if page_id.nil? then
      pages=Page.find_all_by_status(Page::UPLOADED)
    else
      pages=[Page.find(page_id)]
    end

    RemoteWorker.connect_to_server

    logger.info "RemoteWorker called for  #{pages.count} pages!"

    pages.each do |page|
      logger.info "Processing started for page_id #{page.id}  to +#{DRB_WORKER::HOST}"

      page.update_status(Page::UPLOADED_PROCESSING)

      logger.info "Processing file remote: #{page.id}"

      scanned_jpg=File.read(page.tmp_docstore_path)

      ### REMOTE CALL via DRB - the server can run on any server: ruby cd_drb_worker.rb run

      result_jpg, result_sjpg, result_pdf, result_txt=@@processor.convert(scanned_jpg, page.format)

      page.save_file(result_sjpg, :s_jpg)
      page.save_file(result_jpg, :jpg)
      page.save_file(result_pdf, :pdf)
      page.add_content(result_txt)
      page.update_status(Page::UPLOADED_PROCESSED)

      $redis.lpush('converted_pages', page.id.to_s) ### pages processed

      logger.info "Processing file remote: page_id #{page.id}  completed"

    end
  end


end