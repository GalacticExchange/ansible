namespace :test do


  desc 'high load test provision'
  task :stress_test do


    threads = []
    100.times { |t|
      p t
      threads.push(
          Thread.new {
            on roles(:openvpn) do
              exec('sleep 1000')
            end
          }
      )
    }

    threads.each {|thr| thr.join}

  end


  task :test_once do

    on roles(:openvpn) do
      exec('sleep 1000')
    end

  end



  desc 'test lock'
  task :test_lock do
    cluster_id = 468

    #GexLogger.trace_position('start test lock')

    ConsulUtils.connect(cluster_id)

    ConsulUtils.lock_exec(cluster_id, 'master') {
      sleep 60
    }

  end


  desc 'test long'
  task :long do

    run_locally do
      #with rails_env: :development do
        execute %Q(echo "$(date).start" >> /tmp/cap_long.log)
        #execute("touch /tmp/cap_long.log")


        execute %Q(echo "$(date). s2" >> /tmp/cap_long.log)
        #execute("touch /tmp/cap_long.log")
      #end
    end

    %x(echo "$(date). before sleep" >> /tmp/cap_long.log)
    #execute("touch /tmp/cap_long.log")

    sleep(240)

    #execute("touch /tmp/cap_long.log")

    %x(echo "$(date). done sleep" >> /tmp/cap_long.log)

    run_locally do
      #execute("touch /tmp/cap_long.log")
      execute %Q(echo "$(date).finish" >> /tmp/cap_long.log)
    end



  end



end


