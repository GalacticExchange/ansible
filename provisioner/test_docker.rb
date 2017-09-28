#puts "c: #{Config::gex_config}"

#puts "#{Docker::Container.methods}"
#res = Docker::Container.all(all: true, filters: { status: ["running"] }.to_json)
#res = Docker::Container.all(all: true)
conn = Docker::Connection.new('tcp://10.1.0.12:2375', {})

puts "conn: #{conn}"


containers = Docker::Container.all({all: true, filters: { status: ["exited"] }.to_json}, conn)

container = Docker::Container.get("temp1", {}, conn)

puts "container: #{container}"
#puts "container connection: #{container.connection}"

#container.exec("touch /tmp/1.txt")
# [msgs.stdout_messages, msgs.stderr_messages, self.json['ExitCode']]
res_cmd = container.exec(['date'])


puts "cmd res: #{res_cmd}"

#puts "res: #{res}"
containers.each do |r|
  #puts "container #{r.info}"
  #puts "container #{r.info['Names'][0]}"
end
###
exit(0)
