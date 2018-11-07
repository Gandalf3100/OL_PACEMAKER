# -*- mode: ruby -*-
# # vi: set ft=ruby :

unless File.exists?("id_rsa")
 system("ssh-keygen -t rsa -f id_rsa -N '' -q")
end

Vagrant.configure(2) do |config|

  (1..3).each do |i|
    config.vm.define "cluster-node#{i}" do |s|
      s.vm.provider "virtualbox" do |vb|
        vb.memory = 1024
        vb.name = "cluster-node#{i}"
        vb.cpus = 1
#        vb.customize ['modifyvm', :id, '--natnet1', '192.168.50.0/24']
        vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
        vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
      end
      s.ssh.forward_agent = true
      s.vm.box = "ol74"
      s.vm.box_url = "http://yum.oracle.com/boxes/oraclelinux/ol74/ol74.box"
      s.vm.hostname = "cluster-node#{i}"
      s.vm.network "private_network", ip: "192.168.56.10#{i}", netmask: "255.255.255.0"
      if i == 3 
        s.vm.provision :shell, path: "bootstrap.sh", args: "-m"
      else
        s.vm.provision :shell, path: "bootstrap.sh", args: "-n"
      end
    end
  end
end
