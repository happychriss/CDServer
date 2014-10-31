require 'Pusher'

class ScannersController < ApplicationController

  include Pusher

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests


  #### scanner to list devices - called via remote link
  def scan_info
    @scanner_device_list=Scanner.connected_devices
    respond_to(:js) #scan_info.js.erb
  end

  ### called from scanner, this will trigger the Pusher in view, based on subsc
  def scan_status
    @message=params[:message].gsub(/[^0-9a-z ]/i, '-').last(50)
    @scan_complete=(params[:scan_complete]=='true')

    render('scan_status', :handlers => [:erb], :formats => [:js])
  end


  def start_scanner

    color=!params[:color].nil?
    scanner_name=params[:scanner_name]
    Scanner.start_scan(scanner_name,color)

    respond_to(:js)
  end
end
