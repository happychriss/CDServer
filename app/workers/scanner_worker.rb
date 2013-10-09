require 'tmpdir'
require 'Pusher'


class ScannerWorker
  include Sidekiq::Worker
  include Pusher
  include ActionView::Helpers::UrlHelper

  sidekiq_options :retry => false


  def perform(scanner_hash)
    begin
    puts "** Scanner for device #{scanner_hash['current_device']} called"

    res=DRBScanner.instance.processor.scanner_start_scann(scanner_hash['current_device'],scanner_hash['color'])

    puts "** Scanner for device #{scanner_hash['current_device']} completed with res: #{res}"

    rescue Exception => e
      PrivatePub.publish_to "/status", :chat_message => "Hello, world!"
      Log.write_error('ScannerWorker', 'Scann' + '->' +e.message)
      push_status_update ## send status-update to application main page via private_pub gem, fayes,
      raise
    end
  end
end