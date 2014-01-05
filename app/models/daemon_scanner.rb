require 'singleton'
require 'drb'

class DaemonScanner < DaemonConnector

  include Singleton

  attr_accessor :current_device, :color

  def initialize
    super
    @devices=Array.new
    @current_device=''
    @color=false
    @uri="druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port_scanner']}"
  end

  def connected_devices
       if DaemonScanner.instance.drb_connected? then
          if @devices.count==0
              @devices=DaemonScanner.instance.get_processor.scanner_list_devices
          end
       else
         @devices=Array.new
       end

    return @devices
  end


end