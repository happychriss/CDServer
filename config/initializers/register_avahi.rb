t=Thread.new do

  port=Rails::Server.new.options[:Port]

  puts "*** application.rb *****"
  puts "*** Identified as WebServer application - Starting Avahi service Cleandesk on port:#{port}*****"

  DNSSD.register! 'Cleandesk', '_cds._tcp', nil, port
  sleep
end
sleep(1)