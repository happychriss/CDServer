class DaemonConnector

  attr_accessor :connected

  def initialize
    @processor=0
    @connected=false #### set by DRB Daemon on client when active via status controller xxxxx
    @uri=nil
  end

  def connected?
    return @connected
  end

  def enable_connection(do_connect)
    if do_connect then
      self.processor
    else
      @processor=0
      @connected=false
    end

    return @connected

  end

  def processor
    begin
      if @processor!=0 then
        @connected=@processor.me_alive?
      else
        tmp_proc= DRbObject.new_with_uri(@uri) ##
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
        @processor=tmp_proc if tmp_alive
        @connected=tmp_alive
      end

      return @processor

    rescue DRb::DRbConnError => e
      @processor =0
      @connected=false
      puts "ERROR!!!!!!!!!!!! #{self.class.name} not connected to remote host: #{e.message}"
      return @processor
    end

  end

end