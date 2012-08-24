require "fileutils"

class UploadsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(upload_id)
    ## Create small preview image in docstore

    upload=Upload.find(upload_id)
    f=upload.path(:pdf)

    logger.info "Converting file: #{f}"

    res=%x[convert '#{f}' -resize 22% '#{upload.path(:jpg)}']
    logger.info "ERROR - Fist conversion with result: #{res}" unless res==""

    res=%x[convert '#{f}' -resize 220x320  '#{upload.path(:s_jpg)}']
    logger.info "ERROR - Third conversion with result: #{res}" unless res==""

    ## Extract text data and store in database
    res=%x[pdftotext -layout '#{f}']
    logger.info "ERROR - PDF to text with result: #{res}" unless res==""

    text_data=''
    File.open(upload.path(:txt), 'r') { |f| text_data=f.read }

    upload.content=text_data
    upload.save!

    FileUtils.rm(upload.path(:txt))

    logger.info "Conversion completed"
  end

end