class StatusController < ApplicationController

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  #http://stackoverflow.com/questions/9362910/rails-warning-cant-verify-csrf-token-authenticity-for-json-devise-requests

  # GET /status
  # GET /status.json
  def index

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def clear
    Log.clear_all
#    PrivatePub.publish_to "/status", :chat_message => "Hello, world!"
    redirect_to :action => :index
  end

  def start_remote_worker
      RemoteConvertWorker.perform_async(Page.for_batch_conversion)
      redirect_to :action => :index
  end

  def trigger_backup
    BackupWorker.perform_async
    redirect_to :action => :index
  end

  def try_to_connect
    DRBConverter.instance.connect
    redirect_to :action => :index
  end

  def status_drb
    running=params[:running]
    drb_server=params[:drb_server]

    if drb_server=='Converter' then
      DRBConverter.instance.remote_drb_available=(running=='true')
    end

    if drb_server=='Scanner' then
      DRBScanner.instance.remote_drb_available=(running=='true')
    end

    render nothing:true

  end

end
