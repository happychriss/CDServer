class DaemonConnector

  def initialize
    @private_processor=nil
    @uri=nil
  end

  
  ### used from daemon to set connection status for push status update, not nice
  def force_connected(conn)
   if conn then
    @private_processor=1
   else
     @private_processor=nil
   end
  end
  
  def connected?
    not @private_processor.nil?
  end

  def drb_connected?

    connected=false

    unless @private_processor.nil? then
      begin
        connected=@private_processor.me_alive?
      rescue DRb::DRbConnError
        connected=false
      end
    else ## processor ==0
      connected=false
    end

    @private_processor=nil if not connected

    return connected

  end

  def enable_connection(do_connect)

    ### setup connection
    if do_connect then
        @private_processor=nil

        tmp_proc= DRbObject.new_with_uri(@uri) ##

        begin
        tmp_alive=tmp_proc.me_alive? ## somehow only this raises the exception in case of error, me_alive? is a custom method

        if tmp_alive then
          @private_processor=tmp_proc
        else
          @private_processor =nil
          puts "ERROR!!!!!!!!!!!! #{self.class.name} not connected to remote host with uri:#{@uri}"
        end

        rescue DRb::DRbConnError => e
        @private_processor =nil
        puts "ERROR!!!!!!!!!!!! #{self.class.name} not connected to remote host: #{e.message} with uri:#{@uri}"
        return @private_processor
        end

      ### stop connection
    else
      @private_processor=nil
    end

    return self.connected?

  end

  def get_processor
    @private_processor
  end

end