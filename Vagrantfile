# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.define "komp-box" do |vm1|
  config.ssh.private_key_path = "/home/khant/kube-demo/komp-box/.ssh/id_rsa"
  config.ssh.forward_agent = true
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"
    vm1.vm.hostname = "komp-box"
    vm1.vm.box = "bento/ubuntu-24.04"
    vm1.vm.synced_folder ".", "/home/vagrant"
    vm1.vm.network "private_network", ip: "192.168.56.3", :name => "vboxnet0"
    vm1.vm.provider "virtualbox" do |vb|
      vb.name = "komp-box"
      vb.memory = "8192"
      vb.cpus = 4
      vb.gui = false
    end
    vm1.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get install -y net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates gnupg lsb-release software-properties-common
      netstat -tulpn
      echo "Hello from komp-box"
    SHELL

    vm1.vm.provision "shell",
      privileged: true,
      reset: true,
      path: "./scripts/docker-install.sh"

    vm1.vm.provision "shell",
      privileged: true,
      path: "./scripts/kubectl-install.sh"

    vm1.vm.provision "shell",
      privileged: true,
      path: "./scripts/kind-install.sh"

    vm1.vm.provision "shell",
      privileged: true,
      path: "./scripts/helm-install.sh"
  end
end
