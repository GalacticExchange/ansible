class TestProvisionWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'provision', retry: 2


  def perform(*args)
    require_relative 'scripts/restart_webproxy'

    #puts "Doing critical work"
    t = Time.now.utc

    s = args[0]

    File.open('/tmp/sidekiq1.txt', 'a+') { |file| file.puts("start #{s}. #{t}") }
    File.open('/tmp/sidekiq1.txt', 'a+') { |file| file.puts("#{s}. p: #{args}") }

    sleep 120+Random.rand(60)

    t = Time.now.utc
    File.open('/tmp/sidekiq1.txt', 'a+') { |file| file.puts("done #{s}. #{t}") }
  end
end

