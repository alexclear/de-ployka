# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['ANSIBLE_ROLES_PATH'] = "./ansible"

Vagrant.configure(2) do |config|

  config.vm.define "localhost" do |localhost|
    localhost.vm.box='ubuntu/xenial64'
    localhost.vm.provider :virtualbox do |v|
      v.name = "deployka"
    end
  end

  config.vm.provision "shell",
    inline: "apt-get install -y python"
  
  config.vm.provision :ansible do |ansible|
    ansible.playbook = "ansible/test.yml"
    ansible.sudo = true
  end
end
