#
user = 'mmx'
group = 'mmx'


#
num_workers = 1

dir_base = '/projects/ansible/provisioner'
script = 'temp_task_restart.rb'

God.watch do |w|
  w.uid = user
  w.gid = group

  w.name          = "temp-restart"
  w.group         = 'temp'
  w.env           = { }
  w.dir           = dir_base

  #w.pid_file = File.join(app_root, "tmp/pids/", "#{w.name}.pid")
  #w.log           = File.join(app_root, 'log', "#{w.name}.log")

  #
  w.start = "cd #{dir_base} && ruby #{script}"
  #w.stop  = "kill -TERM `cat #{w.pid_file}`"


  #
  #w.keepalive

  #w.behavior(:clean_pid_file)

  #
  w.interval      = 30.seconds
  w.start_grace = 30.seconds
  w.restart_grace = 600.seconds


    w.start_if do |on|
      on.condition(:file_touched) do |c|
        c.interval = 5.seconds
        c.path = File.join(dir_base, 'tmp', 'restart_master.txt')
      end
    end


=begin
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end
=end

=begin
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 300.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end

    restart.condition(:file_touched) do |c|
      c.interval = 5.seconds
      c.path = File.join(app_root, 'tmp', 'restart.txt')
    end

  end

  # after touch tmp/restart.txt
  w.transition(:up, :restart) do |on|
    # restart if server is restarted
    on.condition(:file_touched) do |c|
      c.interval = 5.seconds
      c.path = File.join(app_root, 'tmp', 'restart.txt')
    end
  end


  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end


=end


end
