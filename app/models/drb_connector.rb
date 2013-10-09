class DRBConnector

  attr_accessor :remote_drb_available

  def initialize
    @processor=0
    @connected=false
    @remote_drb_available=true #### set by DRB Daemon on client when active via status controller xxxxx
  end

  def set_uri(uri)
    @uri=uri
  end

  def connected?

    if @remote_drb_available then
      if @connected then
        return true
      else
        self.connect==true ### connect
        return true
      end
    else
      return false
    end
  end

  def processor
    unless self.connected? then
      if self.connect==false then
        raise "DRB Connection ERROR for #{self.class.name}"
      end
    end

    puts "DRB Status: #{self.class.name} processor returned"
    return @processor

  end


  def connect
    if @processor!=0 then
      begin
        @connected=@processor.me_alive?
        puts "DRB Status: #{self.class.name} Connected"
      rescue
        puts "DRB Status: #{self.class.name} Not connected, need to re-connect"
        @connected=false
      end
    end

    unless @connected then
      puts "#{self.class.name} connect to server"
      ## try first to connect to remote host, because he can do all the work
      begin
        tmp_proc= DRbObject.new_with_uri(@uri) ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @processor=tmp_proc if tmp_alive
        @connected=true
      rescue DRb::DRbConnError => e
        @connected=false
        @processor =0
        puts "#{self.class.name} not connected to remote host: #{e.message}"
      end

    end

    return @connected

  end
end