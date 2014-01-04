class DaemonConnector

  attr_accessor :connected

  def initialize
    @processor=0
    @uri=nil
  end

  def connected?
    return @processor!=0
  end

  def drb_connected?

    connected=false

    if @processor=!0 then
      begin
        connected=@processor.me_alive?
      rescue DRb::DRbConnError
        connected=false
      end
    else ## processor ==0
      connected=false
    end

    @processor=0 if not connected

    return connected

  end

  def enable_connection(do_connect)

    ### setup connection
    if do_connect then
      unless self.drb_connected?
        @processor=self.processor
      end
      ### stop connection
    else
      @processor=0
    end

    return self.connected?

  end

  def processor
    begin

      tmp_proc= DRbObject.new_with_uri(@uri) ##
      tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method
      if tmp_alive then
        @processor=tmp_proc
      else
        @processor =0
        puts "ERROR!!!!!!!!!!!! #{self.class.name} not connected to remote host with uri:#{@uri}"
      end

      return @processor

    rescue DRb::DRbConnError => e
      @processor =0
      puts "ERROR!!!!!!!!!!!! #{self.class.name} not connected to remote host: #{e.message} with uri:#{@uri}"
      return @processor
    end

  end

end