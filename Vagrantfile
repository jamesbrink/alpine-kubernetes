# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.box = "alpine/alpine64"
  config.vm.provision "file", source: "./kubelet", destination: "$HOME/kubelet"
  config.vm.provision "file", source: "./shutdown.sh", destination: "$HOME/shutdown.sh"
  config.vm.provision "shell", path: "./provision.sh"
  config.vm.provider "virtualbox" do |vb|
    vb.name = "alpine-k8s-master"
    vb.cpus = 2
    vb.memory = "4096"
  end
end
