---
title: "Running Multiple Vagrant Boxes and the Ansible Provisioner"
date: 2024-06-09 16:15:00
tags:
- linux
- fedora
- vagrant
- ansible
---

## Overview
Building on what we learned in [Setting up Vagrant under Libvirt on Fedora](https://wmcdonald404.github.io/github-pages/2024/03/20/18-51-00-linux-vagrant-libvirt-on-fedora.html), Vagrant can provision [multiple boxes](https://developer.hashicorp.com/vagrant/docs/multi-machine) to help produce (or reproduce) more complex, interconnected [n-tier](https://en.wikipedia.org/wiki/Multitier_architecture) architectures locally. 

For example, this could prove useful if you wanted to mock or test against a simple application server/database server duo.

Vagrant also has the concept of [provisioning/provisioners](https://developer.hashicorp.com/vagrant/docs/provisioning) which permit further extended configuration or orchestration once Vagrant boxes are stood-up. Vagrant's [Ansible provisioner](https://developer.hashicorp.com/vagrant/docs/provisioning/ansible) allows us to run post-provision playbooks against one or more Vagrant boxes on startup.


## How-to
1. Set a working directory for our Vagrant configuration and export an environment variable to use as shorthand for the location:
    ```
    wmcdonald@fedora:~$ mkdir -p ~/working/vagrant/fedora/multi-box-ansible
    wmcdonald@fedora:~$ export VWD=$_
    wmcdonald@fedora:~$ echo $VWD
    /home/wmcdonald/working/vagrant/fedora/multi-box-ansible
    ```

2. Create a Vagrantfile `${VWD}/Vagrantfile` to provision 2 new nodes. Note the `node.vm.provision "ansible"` looping construct which will run the Ansible provisioner for each node.
    ```
    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    Vagrant.configure(2) do |config|
      #Define the number of nodes to spin up
      N = 2

      #Iterate over nodes
      (1..N).each do |node_id|
        nid = (node_id - 1)

        config.vm.define "node#{nid}" do |node|
          node.vm.box = "fedora/40-cloud-base"
          node.vm.provider "libvirt" do |vb|
            vb.memory = "1024"
          end
          node.vm.hostname = "node#{nid}"

          if node_id == N
            node.vm.provision "ansible" do |ansible|
              ansible.limit = "all"
              ansible.groups = {
                "cluster_nodes" => [
                  "node0",
                  "node1",
                ]
              }
              ansible.playbook = "playbook.yml"
            end
          end

        end
      end
    end
    ```

3. Create a simple Ansible playbook, `${VWD}/playbook.yml`.

    ```
    - name: Vagrant post-provision
      hosts: cluster_nodes

      tasks:
      - name: Debug vars for hosts
        debug:
          var: ansible_play_hosts
    ```

4. If the base Vagrant box isn't already set up, set it up for the appropriate hypervisor:
    
    ```
    wmcdonald@fedora:~$ vagrant box add fedora/40-cloud-base --provider libvirt
    ==> box: Loading metadata for box 'fedora/40-cloud-base'
        box: URL: https://vagrantcloud.com/api/v2/vagrant/fedora/40-cloud-base
    ==> box: Adding box 'fedora/40-cloud-base' (v40.20240414.0) for provider: libvirt (amd64)
        box: Downloading: https://vagrantcloud.com/fedora/boxes/40-cloud-base/versions/40.20240414.0/providers/libvirt/amd64/vagrant.box
    Download redirected to host: dl.fedoraproject.org
        box: Calculating and comparing box checksum...
    ==> box: Successfully added box 'fedora/40-cloud-base' (v40.20240414.0) for 'libvirt (amd64)'!
    ```

5. You may need to update the Vagrant plugin `vagrant-libvirt` if you have performed an in-place upgrade of Fedora (e.g. F38 -> F39 or F40):

    *Note:* if you receive the error: 
    > The provider 'libvirt' could not be found, but was requested to back the machine 'node0'. Please use a provider that exists.

    ```
    wmcdonald@fedora:~$ vagrant plugin install vagrant-libvirt
    ```

6. Now we can `vagrant up` the boxes
    ```
    wmcdonald@fedora:~/working/vagrant/fedora/multi-box-ansible$ vagrant up 
    Bringing machine 'node0' up with 'libvirt' provider...
    Bringing machine 'node1' up with 'libvirt' provider...
    ==> node1: Checking if box 'fedora/40-cloud-base' version '40.20240414.0' is up to date...
    ==> node0: Checking if box 'fedora/40-cloud-base' version '40.20240414.0' is up to date...

    <output snipped>

    ==> node0: Uploading base box image as volume into Libvirt storage...
    ==> node1: Running provisioner: ansible...

    PLAY [Vagrant post-provision] **************************************************

    TASK [Gathering Facts] *********************************************************
    ok: [node0]
    ok: [node1]

    TASK [Debug vars for hosts] ****************************************************
    ok: [node0] => {
        "ansible_play_hosts": [
            "node0",
            "node1"
        ]
    }
    ok: [node1] => {
        "ansible_play_hosts": [
            "node0",
            "node1"
        ]
    }

    PLAY RECAP *********************************************************************
    node0                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    node1                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
    ```

    *Note:* Observe the output of `ansible-playbook playbook.yml` among the Vagrant box configuration and provisioning.

## Further reading

- [Setting up Vagrant under Libvirt on Fedora](https://wmcdonald404.github.io/github-pages/2024/03/20/18-51-00-linux-vagrant-libvirt-on-fedora.html)
- [Vagrant Multi-Machine](https://developer.hashicorp.com/vagrant/docs/multi-machine) 
- [Wikipedia Multitier architecture](https://en.wikipedia.org/wiki/Multitier_architecture)
- [Vagrant provisioning/provisioners](https://developer.hashicorp.com/vagrant/docs/provisioning) 
- [The Vagrant Ansible provisioner](https://developer.hashicorp.com/vagrant/docs/provisioning/ansible)