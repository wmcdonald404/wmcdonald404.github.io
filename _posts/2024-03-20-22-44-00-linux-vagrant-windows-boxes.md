---
title: "Linux - Vagrant - Running Windows 2022 on Vagrant with the Libvirt Provider"
date: 2024-03-22 18-51-00
---

## Overview
In [Linux - Vagrant - Setting up Vagrant on Fedora] we outlined the process to set up and test basic Vagrant functionality on Fedora using Libvirt as the virtualisation provider (other providers are available.)

Next we would like to deploy a single Windows host which we can interact with via PSRemoting in order to streamline Windows automation workflows and testing.

There are a number of Windows 2022 Vagrant Box base images available in the Vagrant Box library. In order to run Windows Vagrant boxes on Fedora we need to filter on Libvirt as the virtualisation provider which leads us to https://app.vagrantup.com/jborean93/boxes/WindowsServer2022

## How-to
1. Add a Windows vagrant box base image (https://app.vagrantup.com/jborean93/boxes/WindowsServer2022):
```
$ vagrant box add jborean93/WindowsServer2022 --provider libvirt
==> box: Loading metadata for box 'jborean93/WindowsServer2022'
    box: URL: https://vagrantcloud.com/api/v2/vagrant/jborean93/WindowsServer2022
==> box: Adding box 'jborean93/WindowsServer2022' (v1.2.0) for provider: libvirt (amd64)
    box: Downloading: https://vagrantcloud.com/jborean93/boxes/WindowsServer2022/versions/1.2.0/providers/libvirt/amd64/vagrant.box
    box: Calculating and comparing box checksum...
==> box: Successfully added box 'jborean93/WindowsServer2022' (v1.2.0) for 'libvirt (amd64)'!
```

2. Vagrant init a new box:
```
$ mkdir ~/working/vagrant/windows-scratch
$ cd $_
$ vagrant init jborean93/WindowsServer2022 
A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.
```

3. Vagrant up the box:
```
$ vagrant up
Bringing machine 'default' up with 'libvirt' provider...
==> default: Checking if box 'jborean93/WindowsServer2022' version '1.2.0' is up to date...
==> default: Uploading base box image as volume into Libvirt storage...
==> default: Creating image (snapshot of base box volume).
==> default: Creating domain with the following settings...
==> default:  -- Name:              windows-scratch_default
==> default:  -- Description:       Source: /home/wmcdonald/working/vagrant/windows-scratch/Vagrantfile
==> default:  -- Domain type:       kvm
==> default:  -- Cpus:              2
==> default:  -- Feature:           acpi
==> default:  -- Feature:           apic
==> default:  -- Feature:           pae
==> default:  -- Feature (HyperV):  name=relaxed, state=on
==> default:  -- Feature (HyperV):  name=spinlocks, state=on, retries=8191
==> default:  -- Feature (HyperV):  name=vapic, state=on
==> default:  -- Clock offset:      localtime
==> default:  -- Clock timer:       name=hypervclock, present=yes
==> default:  -- Memory:            2048M
==> default:  -- Base box:          jborean93/WindowsServer2022
==> default:  -- Storage pool:      default
==> default:  -- Image(vda):        /var/lib/libvirt/images/windows-scratch_default.img, virtio, 40G
==> default:  -- Disk driver opts:  cache='default'
==> default:  -- Graphics Type:     vnc
==> default:  -- Video Type:        qxl
==> default:  -- Video VRAM:        16384
==> default:  -- Video 3D accel:    false
==> default:  -- Keymap:            en-us
==> default:  -- TPM Backend:       passthrough
==> default:  -- INPUT:             type=tablet, bus=usb
==> default:  -- USB controller:    model=qemu-xhci
==> default: Creating shared folders metadata...
==> default: Starting domain.
==> default: Domain launching with graphics connection settings...
==> default:  -- Graphics Port:      5900
==> default:  -- Graphics IP:        127.0.0.1
==> default:  -- Graphics Password:  Not defined
==> default:  -- Graphics Websocket: 5700
==> default: Waiting for domain to get an IP address...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: WinRM address: 192.168.121.108:5986
    default: WinRM username: vagrant
    default: WinRM execution_time_limit: PT2H
    default: WinRM transport: ssl
```

4. Test access to the Vagrant box:
```
$ vagrant ssh
vagrant@192.168.121.8's password: <default vagrant password: vagrant>
vagrant@WIN-JSJO34QHSE7 C:\Users\vagrant> pwsh
PS C:\Users\vagrant> $env:COMPUTERNAME
WIN-JSJO34QHSE7
```

5. Halt and destroy the box:
```
PS C:\Users\vagrant> exit
vagrant@WIN-JSJO34QHSE7 C:\Users\vagrant> exit
$ vagrant halt
$ vagrant destroy
```

6. Simplify the default Vagrant file to improve readability: 
```
$ grep -Ev '^.*#|^$' Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "jborean93/WindowsServer2022"
end
$ grep -Ev '^.*#|^$' Vagrantfile > Vagrantfile.bare
$ mv  Vagrantfile Vagrantfile.comments
$ cp  Vagrantfile.bare Vagrantfile 
$ cat Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "jborean93/WindowsServer2022"
end
```

7. Add new block devices for experimentation:
```
$ cat Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "jborean93/WindowsServer2022"
  config.vm.provider :libvirt do |libvirt|
    (0..3).each do |i|
      libvirt.storage :file, :size => '2GB', name: "disk-#{i}"
    end
  end
end
```

8. And reinstantiate the box:
```
$ vagrant up
$ vagrant ssh
vagrant@192.168.121.8's password: <default vagrant password: vagrant>
vagrant@WIN-JSJO34QHSE7 C:\Users\vagrant> pwsh
PS C:\Users\vagrant> get-disk | Select-Object Number, HealthStatus, OperationalStatus, Size
```
  
Number HealthStatus OperationalStatus        Size
------ ------------ -----------------        ----
    1 Healthy      Offline            2000000000
    0 Healthy      Online            42949672960
    3 Healthy      Offline            2000000000
    4 Healthy      Offline            2000000000
    2 Healthy      Offline            2000000000

## Next steps


## Notes

## Further reading
- https://app.vagrantup.com/jborean93/boxes/WindowsServer2022