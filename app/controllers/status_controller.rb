class StatusController < ApplicationController
  # GET /status
  # GET /status.json
  def index

    @connected=ConvertWorker.connect_to_server

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
    ConvertWorker.connect_to_server
    ConvertWorker.perform_async
    redirect_to :action => :index
  end



end
