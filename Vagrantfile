Vagrant.configure("2") do |config|

    cluster.each_with_index do |(hostname, specify), index|
  
      config.vm.define hostname do |cfg|
        cfg.vm.provider :virtualbox do |vb, override|
          config.vm.box = "ubuntu/trusty64"
          override.vm.hostname = hostname
          override.vm.network "private_network", ip: "#{specify[:vm_ip]}"
          vb.name = hostname
          vb.customize ["modifyvm", :id, "--memory", specify[:vm_memory]]
        end
      end
    end
  end