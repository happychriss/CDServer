require 'singleton'
require 'drb'


class DRBConnector

  include Singleton

  def initialize
    @processor=0
    @connected=false
  end

  def connected?
    self.connect==true
  end

  def processor
    if self.connected? then
      return @processor
    else
      raise "DRB Connection ERROR"
    end
  end


  def connect
    if @processor!=0 then
      begin
        @connected=@processor.me_alive?
        puts "DRB Status: Connected"
       rescue
     puts "DRB Status: Not connected, need to re-connect"
        @connected=false
      end
    end

    unless @connected then
      puts "connect to server"
      ## try first to connect to remote host, because he can do all the work
      begin
        tmp_proc= DRbObject.new_with_uri("druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port']}") ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @processor=tmp_proc if tmp_alive
        @connected=true
      rescue DRb::DRbConnError => e
        @connected=false
        @processor =0
        puts "not connected to remote host: #{e.message}"
      end

    end

    return @connected

  end


end