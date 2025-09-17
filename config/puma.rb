if ENV['RAILS_ENV'] == 'production'
  app_dir = File.expand_path("../..", __FILE__)

  bind "unix://#{app_dir}/tmp/sockets/puma.sock"
  pidfile "#{app_dir}/tmp/pids/puma.pid"
  state_path "#{app_dir}/tmp/pids/puma.state"
  stdout_redirect "#{app_dir}/log/puma.access.log", "#{app_dir}/log/puma.error.log", true

  workers 2
  threads 1, 6

  preload_app!

  plugin :tmp_restart
else
  threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
  threads threads_count, threads_count

  port ENV.fetch("PORT", 3000)

  plugin :tmp_restart
  plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]
  pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
end
