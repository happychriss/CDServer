### Starts a server for gpio access as sudo and anounces it service via ahahi, so other can query it and use it

require 'sunxi_server/drb_pin'
require 'drb'
require 'drb/acl'
require 'dnssd'

Signal.trap("INT") do
  puts "\nTerminated"
  $stdout.flush
  exit
end


port=0; env=''
ARGV.each_with_index do |a, i|
  port=ARGV[i+1].to_i if a=='-p'
  env =ARGV[i+1] if a=='-e'

end

########## Start DRB-SERVER ####################################################

drb_uri="druby://localhost:#{port}"
#URI='druby://10.237.48.91:8780'


puts "****** Start DRB Gpio-Server on #{drb_uri}***"

list = %w[
          deny all
          allow localhost
          allow 10.237.48.*
]

acl = ACL.new(list, ACL::DENY_ALLOW)
DRb.install_acl(acl)


front_object=SunxiServer::DRB_PinFactory.new
$SAFE = 1 # disable eval() and friends
DRb.start_service(drb_uri, front_object)

########## Start Avahi-Server ####################################################


puts "****** Start avahi register***"
puts "Port:#{port} and Name:gpioserver_#{env}"
$stdout.flush
DNSSD.register! "gpioserver_#{env}", '_cds._tcp', nil, port
puts "****** Completed avahi register***"
$stdout.flush
sleep
