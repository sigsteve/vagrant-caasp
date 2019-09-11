Vagrant.configure("2") do |config|
    domain          = "suselab.com"
    lbcount         = 2
    mastercount     = 3
    workercount     = 5
    storagecount    = 1

    1.upto(*mastercount) do |i|
        config.vm.define "caasp4-master-#{i}" do |sle|
            sle.vm.box = "sle15sp1"
            sle.vm.hostname = "caasp4-master-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            #sle.vm.provision "shell", inline: "kubeadm config images pull"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false, type: "nfs",
                :mount_options => ['noatime,soft,nfsvers=3'],
                linux__nfs_options: ['rw','no_subtree_check','no_root_squash','async']
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:01:0#{i}"
                #lv.storage :file, :size => '20G'
                lv.memory = "2048"
                lv.cpus   = 2 
            end 
        end
    end 
  
    1.upto(*workercount) do |i|
        config.vm.define "caasp4-worker-#{i}" do |sle|
            sle.vm.box = "sle15sp1"
            sle.vm.hostname = "caasp4-worker-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false, type: "nfs",
                :mount_options => ['noatime,soft,nfsvers=3'],
                linux__nfs_options: ['rw','no_subtree_check','no_root_squash','async']
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:02:0#{i}"
                #lv.storage :file, :size => '20G'
                lv.memory = "2048"
                lv.cpus   = 2
            end
        end
    end

    1.upto(*lbcount) do |i|
        config.vm.define "caasp4-lb-#{i}" do |sle|
            sle.vm.box = "sle15sp1"
            sle.vm.hostname = "caasp4-lb-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/setup_lb.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false,  type: "nfs"
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:03:0#{i}"
                lv.memory = "512"
                lv.cpus   = 1 
            end 
        end
    end 

    1.upto(*storagecount) do |i|
        config.vm.define "caasp4-storage-#{i}" do |sle|
            sle.vm.box = "sle15sp1"
            sle.vm.hostname = "caasp4-storage-#{i}.#{domain}"
            sle.vm.provision "shell", inline: "hostnamectl set-hostname #{sle.vm.hostname}"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/prep_box.sh"
            sle.vm.provision "shell", inline: "/vagrant/boxfiles/setup_nfs_server.sh"
            sle.vm.synced_folder ".", "/vagrant", disabled: false, type: "nfs"
            sle.vm.provider :libvirt do |lv|
                lv.management_network_mac = "52:50:05:AA:04:0#{i}"
                lv.memory = "512"
                lv.cpus   = 1 
            end 
        end
    end 
end
