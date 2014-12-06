
require 'ServiceConnector'

class Scanner


  extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Scanner"
  end

  attr_accessor :current_device, :color

  def self.start_scan(scanner_name,color)

    if self.connected?
      self.get_drb.scanner_start_scann(scanner_name,color)
    else
      Log.write_error('ScannerWorker', 'Not connected to scanner')
      push_app_status ## send status-update to application main page via private_pub gem, fayes,
    end

  end

    def self.connected_devices
    if self.connected?
      self.get_drb.scanner_list_devices
    else
      Array.new
    end

  end


end