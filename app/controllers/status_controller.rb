class StatusController < ApplicationController
  # GET /status
  # GET /status.json
  def index
    @logs= Log.order('created_at desc').all

    #### Backup status
    @pages_no_backup=Page.where('backup=0').count

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @status }
    end
  end


end
