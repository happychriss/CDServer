## included by models that are implemented as remote objects
# it is  working in 3 steps
# 1) check if a valid connection exists in the @@drb_connection (class variable)
# 2) if not it will create a connection based in the database connection
# The remote daemon is calling connection.create / connection.delete to announce the status
# The remote daemon is listening to avahi-server running as initializer (avahi_anounce), if he sees a server to respond
# he will trigger a post call to create the connection

require 'drb/drb'

module ServiceConnector


  def drb_connected?(drb)
    connected=false
    begin
      connected=drb.alive?
    rescue DRb::DRbConnError
      connected=false
    end
    return connected
  end


  def connected?
    not get_drb.nil? ## return true if not nil, meaning drb object found
  end

  def connect
    drb=get_drb
    return false if drb.nil?
    drb_connected?(drb)
  end


  def get_drb

    begin

      puts "*********** Run via DRB***************+"

      ##http://dalibornasevic.com/posts/9-ruby-singleton-pattern  class variables as singelton
      @@drb_connections||=Hash.new

      ## check if service is registered in DB

      connection=Connector.find_service(self.service_name)

      puts "*********** found no connections***************" if connection.nil?

      puts "*********** found :#{connection.inspect}***************" unless connection.nil?

      ## check if a connection is stored in the database, that can be used
      return nil if connection.nil?

      ## check of the DRB object still works, if not remove the DRB object
      drb=@@drb_connections[connection.uid]
      if !drb.nil? and drb_connected?(drb) then
        puts "********* Found working DRB connection"
        return drb
      else
        puts "********* Found not working DRB connection"
        @@drb_connections.delete(connection.uid)
      end

      ### create a new connection from the database

      puts "************* Creating new conenction*********"
      drb= DRb::DRbObject.new_with_uri(connection.uri) ##
      puts "****DRB Object #{drb} *****************"
      if drb_connected?(drb) then
        @@drb_connections[connection.uid]=drb
        puts "***** DRB Class #{@@drb_connections.inspect}**********"
        return drb
      end

      nil
    rescue Exception => e
      Log.write_error('DRBConnection - ServiceConnector', e.message)
      raise
    end

  end

end

