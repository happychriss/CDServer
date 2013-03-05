## Create small preview image in docstore
## called when a page is uploaded

require "fileutils"
require 'drb'

class RemoteWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  @@processor=0

  def perform(page_id)

    logger.info "RemoteWorker started for page_id #{page_id}"

    if @@processor==0 then
      @@processor = DRbObject.new(nil, 'druby://localhost:9000')
      logger.info "Init DRB done!!"
    end

    page=Page.find(page_id)

    logger.info "Processing file remote: #{page_id}"

    scanned_jpg=File.read(page.path(:scanned_jpg))
    result_jpg, result_sjpg, result_pdf, result_txt=@@processor.convert(scanned_jpg)

    page.save_file(result_sjpg, :s_jpg)
    page.save_file(result_jpg, :jpg)
    page.save_file(result_pdf, :pdf)
    page.add_content(result_txt)

    $redis.lpush('converted_pages', page.id.to_s) ### pages processed

    logger.info "Processing file remote: page_id #{page.id} doc_id #{page.document_id}completed"

  end
end