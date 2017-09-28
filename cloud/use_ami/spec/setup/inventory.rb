inventory = {

    openvpn: {
        host: '51.0.1.8',
        ssh_username: 'vagrant',
        ssh_pwd: 'vagrant'
    },

    provisioner: {
        host: '51.0.1.zz',
        ssh_username: 'vagrant',
        ssh_pwd: 'vagrant'
    }

}

#p inventory[:openvpn]
#inventory.each { |o| p o[1][:host] }