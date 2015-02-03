RAILS_PROJECT_ROOT="//home/cds/CDServer"
PID_DIR = "#{RAILS_PROJECT_ROOT}/tmp/pids"
LOG_DIR= "#{RAILS_PROJECT_ROOT}/log"
NGINX_ROOT="/usr/local/nginx/sbin" #config in /usr/local/nginx/conf/nginx.conf
THIN_ROOT="//home/cds/.rvm/gems/ruby-2.1.0/bin/thin"
THIN_CONFIG=File.join(RAILS_PROJECT_ROOT,"thin_nginx.yml")
RVM_BIN="//home/cds/.rvm/bin"


## e.g. bootup_rake in RVM Bin folder
def rvm_bin(daemon)
  return File.join(RVM_BIN,"bootup_"+daemon+" ")
end

God.watch do |w|
  w.name          = "sphinx"
  w.group         ='cds'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.dir           = RAILS_PROJECT_ROOT
  w.env 	  = {'RAILS_ENV' => "production" }
  w.start         = rvm_bin('rake')+"ts:start"
  w.stop          = rvm_bin('rake')+"ts:stop"
  w.restart       = rvm_bin('rake')+"ts:restart"
  w.pid_file      = File.join(RAILS_PROJECT_ROOT, 'log', 'searchd.production.pid')
  w.keepalive
end

God.watch do |w|
  w.name          = 'sidekiq'
  w.group         = 'cds'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_grace    = 10.seconds
  w.interval      = 60.seconds
  w.dir           = RAILS_PROJECT_ROOT
  w.start         = rvm_bin('bundle')+"exec sidekiq -e production -c 3 -P #{RAILS_PROJECT_ROOT}/tmp/pids/sidekiq.pid"
  w.stop          = rvm_bin('bundle')+"exec sidekiqctl stop #{RAILS_PROJECT_ROOT}/tmp/pids/sidekiq.pid 5"
  w.keepalive
  w.log         = File.join(RAILS_PROJECT_ROOT, 'log', 'sidekiq.log')
  w.behavior(:clean_pid_file)
#  w.env           = {'HOME' => '/root'} ## for gpg
end

God.watch do |w|
  w.name          = 'clockwork'
  w.group         = 'cds'
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.stop_grace    = 10.seconds
  w.interval      = 60.seconds
  w.dir           = RAILS_PROJECT_ROOT

  w.start         = rvm_bin('bundle')+"exec clockwork ./job/cdserver_maintenance_job.rb & echo $! > #{PID_DIR}/clockwork.pid"
  w.stop          = "kill -QUIT `cat #{PID_DIR}/clockwork.pid`"
  w.keepalive
  w.log           = File.join(RAILS_PROJECT_ROOT, 'log', 'clockwork.log')
  w.behavior(:clean_pid_file)
  w.env           = {'RAILS_ENV' => "production" }
  w.pid_file      = "#{PID_DIR}/clockwork.pid"
end

God.watch do |w|
  w.name          = "thin"
  w.group         ='cds'
  w.dir           = RAILS_PROJECT_ROOT
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.start         = rvm_bin('thin')+"start --config ./thin_nginx.yml --log #{LOG_DIR}/thin.log"
  w.stop          = rvm_bin('thin')+"stop"
  w.restart       = rvm_bin('thin')+"restart"
  w.pid_file      = "#{PID_DIR}/thin.pid" 
  w.log           = "#{LOG_DIR}/thin.log"  
  w.keepalive
end

#fayae - privat pub gem from ryan
God.watch do |w|
  w.name          = "private_pub"
  w.group         ='cds'
  w.dir           = RAILS_PROJECT_ROOT
  w.start_grace   = 10.seconds
  w.restart_grace = 10.seconds
  w.interval      = 60.seconds
  w.env           = {'RAILS_ENV' => "production" }
  w.start         = rvm_bin('rackup')+"private_pub.ru -s thin -E production -P #{RAILS_PROJECT_ROOT}/tmp/pids/private_pub.pid"

  w.log           = File.join(RAILS_PROJECT_ROOT, 'log', 'private_pub.log')
  w.pid_file      = "#{RAILS_PROJECT_ROOT}/tmp/pids/private_pub.pid"
#   w.stop_signal = 'KILL'
  w.keepalive
end

#avahi daemon to regester the converter and scanner
God.watch do |w|
  w.name 	  = "avahi"  
  w.group         ='cds'
  w.dir           = RAILS_PROJECT_ROOT  
  w.start = rvm_bin('bundle')+"exec "+ rvm_bin('ruby')+" #{RAILS_PROJECT_ROOT}/avahi_service_start_port.rb -p 8082 -e production"
  w.log           = "#{LOG_DIR}/avahi.log"  
  w.keepalive
end

