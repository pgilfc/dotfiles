# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV["VAGRANT_EXPERIMENTAL"] = "disks"

$script = <<-SCRIPT
  growpart /dev/sda 4
  btrfs filesystem resize max /
SCRIPT

Vagrant.configure("2") do |config|

    # increase disk size
    config.vm.disk :disk, size: "50GB", primary: true

    config.vm.box = "fedora/41-cloud-base"

    config.vm.provider "virtualbox" do |vb|
      # Display the VirtualBox GUI when booting the machine
      vb.gui = false
      vb.memory = "4096"
      vb.cpus = 4
    end

    # resize partition
    config.vm.provision "shell", inline: $script

    config.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "dependencies.yml"
    end
    # config.vm.provision "shell",
    #   inline: 'echo "$(runuser -u vagrant -- /home/vagrant/.local/bin/mise env)" > /etc/profile.d/mise.sh',
    #   run: "always"
    config.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "environment.yml"
    end
end
