# -*- mode: ruby -*- # vi: set ft=ruby :

require 'yaml'
require 'pp'

config_file = 'config.yml'
config_yml = YAML.load_file(config_file)

# CONFIGURATION='minimal'
# CONFIGURATION='medium'
# CONFIGURATION='large'
#
# Set CAASP_CONFIG_MODEL in your shell env
# to specify which model to use from config.yml
# When running deploy_caasp.sh, specify the model
# with -m <model>
#
# ./deploy_caasp.sh --model large --full
CONFIG_MODEL=ENV.has_key?('CAASP_CONFIG_MODEL') ? ENV["CAASP_CONFIG_MODEL"] : 'minimal'

Vagrant.configure("2") do |config|
    domain          = "suselab.com"
    lbcount         = 2
    mastercount     = 3
    workercount     = 5
    storagecount    = 1

    1.upto(*mastercount) do |i|
        config.vm.define "caasp4-master-#{i}" do |sle|
            sle.vm.box = "vagrant-caasp"
            sle.vm.hostname = "caasp4-master-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            #sle.vm.provision "shell", inline: "kubeadm config images pull"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false, type: "nfs",
                :mount_options => ['noatime,soft,nfsvers=3'],
                linux__nfs_options: ['rw','no_subtree_check','no_root_squash','async']
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:01:0#{i}"
                lv.memory = config_yml[CONFIG_MODEL]['nodes']['master']['memory']
                lv.cpus   = config_yml[CONFIG_MODEL]['nodes']['master']['cpus']
                extra_disks = config_yml[CONFIG_MODEL]['nodes']['master']['extra_disks']
                if extra_disks > 0
                    (1..extra_disks).each do |disk_num|
                      lv.storage :file, :size => config_yml[CONFIG_MODEL]['nodes']['master']['disk_size'] || '40G'
                    end
                end
            end
        end
    end

    1.upto(*workercount) do |i|
        config.vm.define "caasp4-worker-#{i}" do |sle|
            sle.vm.box = "vagrant-caasp"
            sle.vm.hostname = "caasp4-worker-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false, type: "nfs",
                :mount_options => ['noatime,soft,nfsvers=3'],
                linux__nfs_options: ['rw','no_subtree_check','no_root_squash','async']
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:02:0#{i}"
                extra_disks = config_yml[CONFIG_MODEL]['nodes']['worker']['extra_disks']
                if extra_disks > 0
                    (1..extra_disks).each do |disk_num|
                      lv.storage :file, :size => config_yml[CONFIG_MODEL]['nodes']['worker']['disk_size'] || '40G'
                    end
                end
                lv.memory = config_yml[CONFIG_MODEL]['nodes']['worker']['memory']
                lv.cpus   = config_yml[CONFIG_MODEL]['nodes']['worker']['cpus']
            end
        end
    end

    1.upto(*lbcount) do |i|
        config.vm.define "caasp4-lb-#{i}" do |sle|
            sle.vm.box = "vagrant-caasp"
            sle.vm.hostname = "caasp4-lb-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/setup_lb.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false,  type: "nfs"
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:03:0#{i}"
                lv.memory = config_yml[CONFIG_MODEL]['nodes']['loadbalancer']['memory']
                lv.cpus   = config_yml[CONFIG_MODEL]['nodes']['loadbalancer']['cpus']
                extra_disks = config_yml[CONFIG_MODEL]['nodes']['loadbalancer']['extra_disks']
                if extra_disks > 0
                    (1..extra_disks).each do |disk_num|
                      lv.storage :file, :size => config_yml[CONFIG_MODEL]['nodes']['loadbalancer']['disk_size'] || '40G'
                    end
                end
            end
        end
    end

    1.upto(*storagecount) do |i|
        config.vm.define "caasp4-storage-#{i}" do |sle|
            sle.vm.box = "vagrant-caasp"
            sle.vm.hostname = "caasp4-storage-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/setup_nfs_server.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false, type: "nfs"
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:04:0#{i}"
                lv.memory = config_yml[CONFIG_MODEL]['nodes']['storage']['memory']
                lv.cpus   = config_yml[CONFIG_MODEL]['nodes']['storage']['cpus']
                extra_disks = config_yml[CONFIG_MODEL]['nodes']['storage']['extra_disks']
                if extra_disks > 0
                    (1..extra_disks).each do |disk_num|
                      lv.storage :file, :size => config_yml[CONFIG_MODEL]['nodes']['storage']['disk_size'] || '40G'
                    end
                end
            end
        end
    end
end
