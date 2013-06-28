### make a nice daemon out of this to make it start and stopable - running from server
require 'drb'
require 'drb/acl'
require 'daemons'
require_relative '../lib/DRbProcessor'
include DRbProcessor

mode=ARGV[1]

Daemons.run_proc("DRbProcessor_#{mode}.rb", options = {:dir_mode => :normal,:ARGV => ARGV}) do

# ***************************************************************************************************

  $SAFE = 1 # disable eval() and friends

  acl = ACL.new(%w{deny all
                  allow localhost
                  allow 192.168.1.*}) ## from local subnet

  if mode=='remote' then
    puts "In Daemons run_proc in remote mode on port 8999"
    DRb.start_service("druby://0.0.0.0:8999", Processor.new) # replace localhost with 0.0.0.0 to allow conns from outside
  else
    puts "In Daemons run_proc in local qnas mode on port 8998"
    DRb.start_service("druby://0.0.0.0:8998", Processor.new) # replace localhost with 0.0.0.0 to allow conns from outside
  end

  begin
    DRb.thread.join
  rescue Interrupt
  ensure
    DRb.stop_service
  end
end

# ***************************************************************************************************
