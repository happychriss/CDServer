require 'Pusher'

class DrbScannersController < ApplicationController

  include Pusher

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests


  #### scanner to list devices - called via remote link
  def scan_info
    @scanner_available=DRBScanner.instance.scanner_available?
    @scanner_device_list=DRBScanner.instance.devices if @scanner_available
    respond_to(:js) #scan_info.js.erb
  end

  ### called from scanner, this will trigger the Pusher in view, based on subsc
  def scan_status
    @message=params[:message].gsub(/[^0-9a-z ]/i, '-').last(50)
    @scan_complete=(params[:scan_complete]=='true')

    render('scan_status', :handlers => [:erb], :formats => [:js])
  end


  def start_scanner

    DRBScanner.instance.color=!params[:color].nil?
    DRBScanner.instance.current_device=params[:scanner_name]

    if (false) then
      rm=ScannerWorker.new #direct calling

      hash=Hash.new
      DRBScanner.instance.instance_variables.each { |var| hash[var.to_s.delete("@")] = DRBScanner.instance.instance_variable_get(var) }

      rm.perform(hash) #direct calling ##attributes to get a hash
    else
      ScannerWorker.perform_async(DRBScanner.instance)
    end

    respond_to(:js)
  end
end
