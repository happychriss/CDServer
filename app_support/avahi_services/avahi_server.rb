#  ruby avahi_server.rb start
### Register an avahi-service, the service name corrospondents to the DRB object to be implemented at the DRB Server side

require 'dnssd'
require 'daemons'
require 'optparse'


def avahi_register(web_server_port)

  dnssd_register('Converter', web_server_port)
  dnssd_register('Scanner', web_server_port)
  sleep
end

def dnssd_register(service, web_server_port)

  DNSSD.register! service, '_cds._tcp', nil, web_server_port.to_i
  puts "**** DNSSD-Server started for service : #{service} for web-server port: #{web_server_port}*****"

end

# *********************************************************************************
# *********************************************************************************
# *********************************************************************************

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: avahi_server.rb [options]"
  opts.on('-p', '--port PORT', 'Port of the webserver') { |v| options[:port] = v }
end.parse!

web_server_port=options[:port]

if TRUE
  avahi_register(web_server_port)
else
  Daemons.run_proc('avahi_server.rb') do
    begin
      avahi_register(web_server_port)
    rescue Interrupt
    ensure
      puts "DNSSD-Server stopped: server / _cds._tcp"
    end
  end
end