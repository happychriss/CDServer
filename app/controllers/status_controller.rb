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


end
