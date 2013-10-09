require 'singleton'
require 'drb'
require 'drb_connector'

class DRBScanner < DRBConnector

  include Singleton

  attr_reader :connected, :devices

  attr_accessor :current_device, :color

  def initialize
    @connected=false
    @devices=Array.new
    @current_device=''
    @color=false
    super
  end

  def scanner_available?

    if self.connected? then
      @devices=DRBScanner.instance.processor.scanner_list_devices
      if @devices.count!=0 then
        return true
      end
    end
    @devices=[]
    return false
  end


end