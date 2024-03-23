---
title: "Linux - Vagrant - Setting up Vagrant under Libvirt on Fedora"
date: 2024-03-20 22-44-00
---

## Overview
Vagrant can be a useful abstraction layer to streamline provisioning of local, virtualised test environments. Typically it would be used in order to experiment and learn before industrialising, automating and subsequently deploying systems, applications or stacks to on-prem environments or public clouds. Or to shorten feedback loops where further downstream provisioning processes are complex, slow or process-bound.

Many modern SDLC workflows will shift the OS/container to either a cloud-hosted or containerised execution environment like AWS Cloud9 or Visual Studio Code Dev Containers. However it's still incredibly useful to be able to pull OS images, combine and compose them and run locally in a hypervisor in order to [_fuck around and find out_](https://knowyourmeme.com/memes/fuck-around-and-find-out-fafo). For example, running Windows VMs locally on Fedora for lab-ing things or familiarisation, or vice-versa running Linux distros under Virtualbox or Hyper-V.

Chapter-and-verse from the [Vagrant documentation states](https://developer.hashicorp.com/vagrant/tutorials/getting-started/getting-started-index):

> Vagrant is a tool for building complete development environments. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases development/production parity, and makes the "it works on my machine" excuse a relic of the past.
>
> Vagrant is a tool for building and managing virtual machine environments in a single workflow. With an easy-to-use workflow and focus on automation, Vagrant lowers development environment setup time, increases production parity, and makes the "works on my machine" excuse a relic of the past.

Vagrant can run on multiple operating systems, and supplies virtualisation "providers" for many of the most common hypervisors.  It also provides a number of useful "provisioners" which can run Ansible, Puppet, Chef or other scripts to configure or converge a new Vagrant deployment into a desired state once stood-up.

This post will summarise the initial setup on Fedora using Libvirt, ultimately to support the rapid provisioning of Windows systems because that's what I need at the moment.  Historically, it's probably most commonly deployed with Windows and Virtualbox, but many other useful combinations exist. 

## How-to
1. Check for/enable Intel-VT / AMD-V CPU virtualisation extensions. (Don't skip this, they're disabled by default on most laptops and will cause largely silent, annoying failures if not enabled.)

```
$ egrep '^flags.*(vmx|svm)' /proc/cpuinfo
```

2. Install libvirt

```
# dnf -y install @virtualization
```

3. Install libvirt and some dependencies required for vagrant-libvirt later.

```
# dnf -y install gcc libvirt libvirt-devel libxml2-devel make ruby-devel libguestfs-tools
```

(nb: find out why the requisites aren't depended on by vagrant-libvirt? Maybe some variant on https://bugzilla.redhat.com/show_bug.cgi?id=1523296 ?)

4. Install vagrant & the vagrant libvirt plugin

```
# dnf install vagrant vagrant-libvirt
```

5. Enable/start libvirtd.service

```
# systemctl enable libvirtd.service
```

6. Setup the Vagrant libvirt plugin (May or may not be required, need to verify on a clean installation.)

```
$  vagrant plugin install vagrant-libvirt
```

7. Quick hack around https://bugzilla.redhat.com/show_bug.cgi?id=1187019

```
# usermod -G libvirt wmcdonald
```

8. Add a fedora vagrant box base image (https://app.vagrantup.com/fedora/boxes/37-cloud-base)

```
$ vagrant box add fedora/37-cloud-base --provider libvirt
```

9. Init a box and start up

```
$ mkdir working/vagrant/fedora-scratch
$ cd $_
$ vagrant init fedora/37-cloud-base --box-version 37.20221105.0
$ vagrant up
$ vagrant halt
```

## Next steps
Extend the setup to include multiple flavours of Vagrant box, more complex combinations of systems or whatever it is you need in order to shorted feedback loops and/or figure stuff out.

- Add Windows boxes with Powershell remoting enabled. 
- Update the older fedora/37-cloud-base to Fedora 39 or 40.
- Add multiple nodes with provisioner runs.

## Notes
If returning to this after a few months or a year or two, if you've been performing in-place upgrades of Fedora you may encounter plugin version mismatches, for example:
```
wmcdonald@fedora:~$ vagrant box list
Vagrant failed to initialize at a very early stage:

The plugins failed to initialize correctly. This may be due to manual
modifications made within the Vagrant home directory. Vagrant can
attempt to automatically correct this issue by running:

  vagrant plugin repair

If Vagrant was recently updated, this error may be due to incompatible
versions of dependencies. To fix this problem please remove and re-install
all plugins. Vagrant can attempt to do this automatically by running:

  vagrant plugin expunge --reinstall

Or you may want to try updating the installed plugins to their latest
versions:

  vagrant plugin update

Error message given during initialization: Unable to resolve dependency: user requested 'vagrant-libvirt (= 0.11.2)'
```
This can be relatively simply resolved by:
```
wmcdonald@fedora:~$ vagrant plugin update
wmcdonald@fedora:~$ vagrant box list
fedora/37-cloud-base (libvirt, 37.20221105.0)
```

If `vagrant up` fails with the following error:

<<error lost to the mists of time, placeholder until reoccurence>>

Run the following as a temporary mitigation (proper root-cause required):
```sudo virsh net-list --all```

https://github.com/hashicorp/vagrant/issues/12605

## Further reading
- https://computingforgeeks.com/using-vagrant-with-libvirt-on-linux/
- https://app.vagrantup.com/fedora/boxes/37-cloud-base
- https://alt.fedoraproject.org/en/cloud/
- https://app.vagrantup.com/fedora/
- https://download.fedoraproject.org/pub/fedora/linux/releases/37/Cloud/x86_64/images/Fedora-Cloud-Base-Vagrant-37-1.7.x86_64.vagrant-libvirt.box
- https://github.com/vagrant-libvirt/vagrant-libvirt#installing
- https://developer.fedoraproject.org/tools/vagrant/vagrant-libvirt.html
- https://fedoraproject.org/wiki/Changes/LibvirtModularDaemons
- https://fedoramagazine.org/setting-up-a-vm-on-fedora-server-using-cloud-images-and-virt-install-version-3/
- https://blog.while-true-do.io/cloud-init-getting-started/
- https://opensource.com/article/21/10/vagrant-libvirt
- https://github.com/gusztavvargadr/packer/wiki/Windows-Server
