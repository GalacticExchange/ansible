require_relative '../lib/init_script'

ssh_options = {
    hostname: '51.1.0.50',
    port: 22,
    user: 'gex',
    pwd: 'PH_GEX_PASSWD1'
}

res = SshRunner.run(ssh_options, cmd)
puts "res: #{res}"
