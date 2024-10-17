---
title: "Setting up Vagrant under Libvirt on Fedora"
date: 2024-03-20 22:44:00
layout: default
tags:
- linux
- fedora
- libvirt
- vagrant
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

```
wmcdonald@fedora:~/working/vagrant/fedora-scratch$ vagrant up 
Bringing machine 'default' up with 'libvirt' provider...
==> default: Checking if box 'fedora/37-cloud-base' version '37.20221105.0' is up to date...
==> default: Creating image (snapshot of base box volume).
==> default: Creating domain with the following settings...
==> default:  -- Name:              fedora-scratch_default
==> default:  -- Description:       Source: /home/wmcdonald/working/vagrant/fedora-scratch/Vagrantfile
==> default:  -- Domain type:       kvm
==> default:  -- Cpus:              1
==> default:  -- Feature:           acpi
==> default:  -- Feature:           apic
==> default:  -- Feature:           pae
==> default:  -- Clock offset:      utc
==> default:  -- Memory:            1024M
==> default:  -- Base box:          fedora/37-cloud-base
==> default:  -- Storage pool:      default
==> default:  -- Image(vda):        /home/wmcdonald/.local/share/libvirt/images/fedora-scratch_default.img, virtio, 41G
==> default:  -- Disk driver opts:  cache='default'
==> default:  -- Graphics Type:     vnc
==> default:  -- Video Type:        cirrus
==> default:  -- Video VRAM:        16384
==> default:  -- Video 3D accel:    false
==> default:  -- Keymap:            en-us
==> default:  -- TPM Backend:       passthrough
==> default:  -- INPUT:             type=mouse, bus=ps2
==> default: Removing domain...
==> default: Deleting the machine folder
/usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/driver.rb:207:in `list_all_networks': Call to virConnectListAllNetworks failed: Failed to connect socket to '/var/run/libvirt/virtnetworkd-sock-ro': No such file or directory (Libvirt::RetrieveError)
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/driver.rb:207:in `list_all_networks'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/util/network_util.rb:157:in `libvirt_networks'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/create_networks.rb:38:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/create_domain.rb:452:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/resolve_disk_settings.rb:143:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/create_domain_volume.rb:97:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/handle_box_image.rb:127:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builtin/handle_box.rb:56:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/handle_storage_pool.rb:63:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/set_name_of_domain.rb:34:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builtin/provision.rb:80:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-libvirt-0.11.2/lib/vagrant-libvirt/action/cleanup_on_failure.rb:21:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:127:in `block in finalize_action'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builder.rb:180:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/runner.rb:101:in `block in run'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/util/busy.rb:19:in `busy'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/runner.rb:101:in `run'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builtin/call.rb:53:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builtin/box_check_outdated.rb:93:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builtin/config_validate.rb:25:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/warden.rb:48:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/builder.rb:180:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/runner.rb:101:in `block in run'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/util/busy.rb:19:in `busy'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/action/runner.rb:101:in `run'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/machine.rb:248:in `action_raw'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/machine.rb:217:in `block in action'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/environment.rb:631:in `lock'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/machine.rb:203:in `call'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/machine.rb:203:in `action'
	from /usr/share/vagrant/gems/gems/vagrant-2.3.4/lib/vagrant/batch_action.rb:86:in `block (2 levels) in run'
```

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
