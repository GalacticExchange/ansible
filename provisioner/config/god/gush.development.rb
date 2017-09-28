#
#appname = 'provisioner'
app_env = 'development'

puts "gush for god. env=#{app_env}"

#
app_root = "/projects/ansible/provisioner"



# settings
stop_timeout = 1800
concurrency = 10
queue = 'provisiongush'


#
user = 'root'
group = 'root'



#
rake_root = "/home/mmx/.rvm/wrappers/ruby-2.3.3"
bin_path   = "/home/mmx/.rvm/gems/ruby-2.3.3/bin"




God.watch do |w|
  w.uid = user
  w.gid = group

  w.name          = "sidekiq-provision-gush"
  w.group         = 'sidekiq'
  w.env           = { 'RAILS_ENV' => app_env, 'app_env'=>app_env,
                      'queue' => queue,
                      'concurrency' => concurrency,
  }
  w.dir           = app_root

  w.pid_file = File.join(app_root, "tmp/pids/", "#{w.name}.pid")
  w.log      = File.join(app_root, 'log', "#{w.name}.log")


  #
  #sidekiq_options = "-e #{app_env} -t #{stop_timeout}  -c #{sidekiq_concurrency} -q #{sidekiq_queue} -L #{w.log} -P #{w.pid_file}"

  # -d
  w.start = "cd #{app_root}; app_env=#{app_env} nohup #{bin_path}/bundle exec gush workers 2>&1 &"
  #w.stop  = "kill -TERM `cat #{w.pid_file}`"
  #w.stop  = "cd #{app_root} && sidekiqctl stop #{w.pid_file} #{stop_timeout} "


  #
  #w.keepalive
  w.behavior(:clean_pid_file)

  #
  w.interval      = 30.seconds

  w.start_grace = 20.seconds
  w.restart_grace = 20.seconds

  #w.stop_signal = 'QUIT'
  w.stop_timeout = stop_timeout.seconds



  ### restart
  w.restart_if do |on|
    on.condition(:file_touched) do |c|
      c.interval = 5.seconds
      c.path = File.join(app_root, 'tmp', 'restart_sidekiq.txt')
    end

  end




  # from godrb.com
  # determine the state on startup
  w.transition(:init, { true => :up, false => :start }) do |on|
    on.condition(:process_running) do |c|
      c.running = true
    end
  end

  # determine when process has finished starting
  w.transition([:start, :restart], :up) do |on|
    on.condition(:process_running) do |c|
      c.running = true
      c.interval = 5.seconds
    end

    # failsafe
    on.condition(:tries) do |c|
      c.times = 5
      c.transition = :start
      c.interval = 5.seconds
    end
  end

  # start if process is not running
  w.transition(:up, :start) do |on|
    on.condition(:process_running) do |c|
      c.running = false
    end
  end


end
