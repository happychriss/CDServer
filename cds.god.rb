RAILS_PROJECT_ROOT="//share/Web/CDServer"
REDIS_ROOT="//opt/bin"
MYSQL_ROOT="//opt/share/mysql" #config in /opt/etc/my.cnf??
NGINX_ROOT="//opt/sbin" #config in /opt/etc/nginx/nginx.conf

THIN_ROOT="//opt/bin"
THIN_CONFIG=File.join(RAILS_PROJECT_ROOT,"thin_nginx_cdserver.yml")

God.watch do |w|
    w.name          = "mysql"
    w.uid           = 'mysql'
    w.gid           = 'mysql'
    w.group         ='cds'
    w.start_grace   = 10.seconds
    w.restart_grace = 10.seconds
    w.interval      = 30.seconds
    w.start         = File.join(MYSQL_ROOT,'mysql.server start')
    w.stop          = File.join(MYSQL_ROOT,'mysql.server stop')
    w.pid_file      = "//share/Storage/mysql/qnas.pid"
    w.keepalive
end

God.watch do |w|
    w.name          = "redis"
    w.group         ='cds'
    w.interval      = 30.seconds
    w.start         = "#{REDIS_ROOT}/redis-server /opt/etc/redis.conf"
    w.stop          = "#{REDIS_ROOT}/redis-cli shutdown"
    w.restart       = "#{w.stop} && #{w.start}"
    w.start_grace   = 10.seconds
    w.restart_grace = 10.seconds
    w.keepalive
    w.log           = File.join(RAILS_PROJECT_ROOT, 'log', 'redis.log')

    w.start_if do |start|
      start.condition(:process_running) do |c|
          c.interval = 5.seconds
          c.running = false
      end
    end
 end

God.watch do |w|
  w.name        = "sidekiq"
  w.group       = 'cds'
  w.interval    = 20.seconds
  w.dir         = RAILS_PROJECT_ROOT
  w.start       = "bundle exec sidekiq -e production"
  w.stop        = "bundle exec sidekiqctl stop #{RAILS_PROJECT_ROOT}/tmp/pids/sidekiq.pid 5"
  w.keepalive
  w.log         = File.join(RAILS_PROJECT_ROOT, 'log', 'sidekiq.log')
  w.behavior(:clean_pid_file)
end

God.watch do |w|
    w.name          = "nginx"
    w.group         ='cds'
    w.start_grace   = 10.seconds
    w.restart_grace = 10.seconds
    w.interval      = 30.seconds
    w.start         = File.join(NGINX_ROOT,'nginx')
    w.stop          = File.join(NGINX_ROOT,'nginx -s stop')
    w.restart       = File.join(NGINX_ROOT,'nginx -s reload')
    w.pid_file      = "//var/run/nginx.pid";
    w.keepalive
end

God.watch do |w|
    w.name          = "thin"
    w.group         ='cds'
    w.dir           = RAILS_PROJECT_ROOT
    w.start_grace   = 10.seconds
    w.restart_grace = 10.seconds
    w.interval      = 30.seconds
    w.start         = "thin start --config ./thin_nginx.yml"
    w.stop          = "thin stop"
    w.restart	      = "thin restart"
    w.pid_file      = File.join(RAILS_PROJECT_ROOT,"tmp","pids","thin.pid")
    w.keepalive
end
