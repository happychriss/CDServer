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
    ConvertWorker.perform_async
    redirect_to :action => :index
  end

  def show_status

    @converted_pages=Array.new
    @error_messages='NO ERROR'

    while (true)
      page_id=$redis.rpop('converted_pages')
      break if page_id.nil?
      @converted_pages.push(Page.find(page_id.to_i))
    end

    while (true)
      error_msg=$redis.rpop('remote_worker_error')
      break if error_msg.nil?
      @error_messages=@error_messages+error_msg
    end

    @backup_status=$redis.get('backup_status')
    @backup_count=$redis.get('backup_count')

  end

end
