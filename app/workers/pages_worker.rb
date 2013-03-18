## Create small preview image in docstore
################ called when a page is uploaded --- used for local conversions

require "fileutils"

class PagesWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(page_id)
    logger.info "SLEEP"

    logger.info "START Redis Upload for page_id #{page_id}"

    page=Page.find(page_id)
    f=page.path(:pdf)

    logger.info "Converting file: #{f}"

    res=%x[convert '#{f}'[0] -resize 220x320  '#{page.path(:s_jpg)}']
    logger.info "ERROR - Third conversion with result: #{res}" unless res==""
    $redis.lpush('converted_pages',page.id.to_s) ### pages processed

    res=%x[convert '#{f}'[0] -resize x770 '#{page.path(:jpg)}']
    logger.info "ERROR - Fist conversion with result: #{res}" unless res==""

    ## Extract text data and store in database
    res=%x[pdftotext -layout '#{f}']
    logger.info "ERROR - PDF to text with result: #{res}" unless res==""

    text_data=''
    File.open(page.path(:txt), 'r') { |f| text_data=f.read }

    page.add_content(text_data)

    FileUtils.rm(page.path(:txt))

    logger.info "STOP Completed conversion for page_id #{page_id}"
    Log.write("Upload","Completed conversion and upload for page_id: #{page.id}")

  end

end