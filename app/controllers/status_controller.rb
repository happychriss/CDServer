class StatusController < ApplicationController
  # GET /status
  # GET /status.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @status }
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
    DRBConnector.instance.connect
    redirect_to :action => :index
  end


end
