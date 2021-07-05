Vagrant.configure("2") do |config|

    cluster.each_with_index do |(hostname, info), index|
  
      config.vm.define hostname do |cfg|
        cfg.vm.provider :virtualbox do |vb, override|
          config.vm.box = "ubuntu/trusty64"
          override.vm.hostname = hostname
          override.vm.network "private_network", ip: "#{info[:ip]}"
          vb.name = hostname
          vb.customize ["modifyvm", :id, "--memory", info[:mem]]
        end
      end
    end
  end