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
    Log.delete_all
    redirect_to :action => :index
  end

  def start_remote_worker
    RemoteWorker.perform_async
    redirect_to :action => :index
  end

end
