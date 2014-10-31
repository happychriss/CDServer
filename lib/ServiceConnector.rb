module ServiceConnector

  def drb_connected?(drb)
    connected=false
    begin
      connected=drb.me_alive?
    rescue DRb::DRbConnError
      connected=false
    end
    return connected
  end


  def connected?
    run_via_drb!=nil ## return true if not nil, meaning drb object found
  end

  def run_via_drb

    ##http://dalibornasevic.com/posts/9-ruby-singleton-pattern  class variables as singelton
    @@drb_connections||=Hash.new

    ## check if service is registered in DB

    connections=Connection.find_service(self.service_name)

    return nil if connections.nil?

    ## check if a connection is stored in the database, that can be used
    connections.each do |connection|

      ## check of the DRB object still works, if not remove the DRB object

      drb=@@drb_connections[connection.uid]
      if !drb.nil? and drb_connected?(drb) then
        puts "********* Found working DRB connection"
        return drb
      else
        @@drb_connections.delete(connection.uid)
        puts "********* Deleted it"
      end

      ### create a new connection from the database

      drb= DRbObject.new_with_uri(connection.uri) ##
      if drb_connected?(drb) then
        @@drb_connections[connection.uid]=drb
        return drb
      end

    end

    nil

  end


end