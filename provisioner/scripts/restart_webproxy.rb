require_relative '../lib/init_script'

puts "start"

#res_cmd = Provision::DockerUtils.dexec("webproxy", "date")
#res_cmd = Provision::DockerUtils.dexec("webproxy", ['bash' ,'-c', 'touch /tmp/restart.txt'])
res_cmd = Provision::DockerUtils.dexec("webproxy", 'touch /tmp/restart.txt')
#res_cmd = Provision::DockerUtils.dexec("webproxy", "ls -la /tmp")

puts "res: #{res_cmd}"
#exit(0)

# restart nginx for webproxy
#%x[echo '1' >> /tmp/restart_webproxy.txt]
#%x[echo "$(date). webproxy" >> /tmp/restart_webproxy.txt]

puts "finish"
