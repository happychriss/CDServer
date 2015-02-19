require 'ServiceConnector'

class Hardware
  extend ServiceConnector ##provides methods to connect to remote drb services

  def self.service_name
    "Iocontroller"
  end

  def self.blink_ok_status_led
    self.get_drb.blink_ok_status_led
  end

  def self.watch_scanner_button_on
    self.get_drb.watch_scanner_start_button
  end
end