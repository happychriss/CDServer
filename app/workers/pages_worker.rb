require "fileutils"

class PagesWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(page_id)
    ## Create small preview image in docstore

    upload_count=$redis.incr('upload_count')
    logger.info "START Redis Initial Upload Count #{upload_count}"

    page=Page.find(page_id)
    f=page.path(:pdf)

    logger.info "Converting file: #{f}"

    res=%x[convert '#{f}' -resize 22% '#{page.path(:jpg)}']
    logger.info "ERROR - Fist conversion with result: #{res}" unless res==""

    res=%x[convert '#{f}' -resize 220x320  '#{page.path(:s_jpg)}']
    logger.info "ERROR - Third conversion with result: #{res}" unless res==""

    ## Extract text data and store in database
    res=%x[pdftotext -layout '#{f}']
    logger.info "ERROR - PDF to text with result: #{res}" unless res==""

    text_data=''
    File.open(page.path(:txt), 'r') { |f| text_data=f.read }

    page.add_content(text_data)

    FileUtils.rm(page.path(:txt))

    logger.info "Conversion completed"
    upload_count=$redis.decr('upload_count')
    logger.info "STOP Redis Initial Upload Count #{upload_count}"

  end

end