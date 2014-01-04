require 'Pusher'
class StatusController < ApplicationController

  include Pusher

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests

  # GET /status
  # GET /status.json
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  #### Clear Logfile, called from Status-Page
  def clear
    Log.clear_all
#    PrivatePub.publish_to "/status", :chat_message => "Hello, world!"
    redirect_to :action => :index
  end

  def start_remote_worker
    RemoteConvertWorker.my_perform(Page.for_batch_conversion)
    redirect_to :action => :index
  end

  def trigger_backup
    BackupWorker.perform_async
    redirect_to :action => :index
  end

  def try_to_connect
    DaemonConverter.instance.enable_connection(true)
    redirect_to :action => :index
  end

  ############################### External calls




  ### Called from CDDaemon
  def status_drb
    running=params[:running]
    drb_server=params[:drb_server]

    if drb_server=='Converter' then

      DaemonConverter.instance.enable_connection(running=='true')

      if DaemonConverter.instance.connected? then
        RemoteConvertWorker.my_perform(Page.for_batch_conversion)
      end

      push_status_update

    end

    if drb_server=='Scanner' then
      DaemonScanner.instance.enable_connection(running=='true')
    end

    render nothing: true

  end


end
