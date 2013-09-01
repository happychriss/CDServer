require 'singleton'

class DRBConnector

  include Singleton

  def initialize
    @processor=0
    @status=NOT_CONNECTED
  end


  def connected?
    self.connect==NOT_CONNECTED
  end

  def processor
    if self.connect then
    return @processor
    else
      raise "DRB Connection ERROR"
    end
  end

  private
  def connect
    if @processor!=0 then
      begin
        @processor.tmp_alive?
      rescue
        @status=NOT_CONNECTED
      end
    end
    puts "connect to server"

    if @status==NOT_CONNECTED then

      ## try first to connect to remote host, because he can do all the work
      begin
        tmp_proc= DRbObject.new(nil, "druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port']}") ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @processor=tmp_proc if tmp_alive
        @status=CONNECTED_TO_REMOTE
      rescue DRb::DRbConnError => e
        @status=NOT_CONNECTED
        @processor =0
        puts "not connected to remote host: #{e.message}"
      end

    end

    return @status

  end


end