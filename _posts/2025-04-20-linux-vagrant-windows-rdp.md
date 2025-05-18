---
title: "RDP to Windows 2022 running on Vagrant with the Libvirt Provider"
tags:
- linux
- fedora
- libvirt
- vagrant
- microsoft
- windows
- rdp
---

* TOC
{:toc}

## Overview
In [Running Windows 2022 on Vagrant with the Libvirt Provider](https://wmcdonald404.co.uk/2024/03/20/linux-vagrant-windows-boxes.html) we outlined the process to set up and test basic Vagrant functionality in Windows on Fedora using Libvirt as the virtualisation provider (other providers are available.) We covered deploying a single Windows host which we can interact with via PSRemoting in order to streamline Windows automation workflows and testing.

Now if we needed to be able to RDP to an instance, for example to visualise configuration change as a result of Powershell automation (or Ansible, or anything else). We'll cover the Fedora-side pre-requisites and any post-provisioning steps.

## How-to
### Initial Fedora config
1. If it's been a while since running this Vagrant box (and some in-place Fedora upgrades have occured).
  
    ```shell
    $ vagrant plugin expunge --reinstall
    $ vagrant plugin install winrm
    $ vagrant plugin install winrm-fs
    $ vagrant plugin install winrm-elevated
    $ sudo virsh net-list --all
    ```

2. Create a new Vagrant config for the specific purpose of RDP:

    ```shell
    $ cp -a ~/repos/wmcdonald404/vagrantfiles/jborean93/windows2022 ~/repos/wmcdonald404/vagrantfiles/jborean93/windows2022-rdp/
    ```

### Windows config
1. Manually enable RDP connections into the Vagrant box and open the firewall.
  
    ```
    $ vagrant ssh
    Microsoft Windows [Version 10.0.20348.2031]
    (c) Microsoft Corporation. All rights reserved.
    vagrant@WIN-K5L3P3IJUBT C:\Users\vagrant>pwsh
    PowerShell 7.3.8
    PS C:\Users\vagrant> Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0 
    PS C:\Users\vagrant> Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    PS C:\Users\vagrant> exit
    ```
    
    **Note:** The [Jborean Windows 2022 image](https://portal.cloud.hashicorp.com/vagrant/discover/jborean93/WindowsServer2022) appears to already have the Terminal Services service enabled and the firewall rule(s) enabled.

### Subsequent Fedora config

Now we should be able to connect to the Windows Vagrant box via RDP.

1. List the RDP properties...

    ```shell
    $ vagrant winrm-config
    Host default
      HostName 192.168.0.147
      User vagrant
      Password vagrant
      Port 5986
      RDPHostName 192.168.0.147
      RDPPort 3389
      RDPUser vagrant
      RDPPassword vagrant
    ```

2. Connect to the Vagrant VM using the default credentials.

    **Note:** `wlfreerdp` is deprecated and `sdl-freerdp` is prefered. Its usage is essentially the same as wlfreerdp.

    ```shell
    $ wlfreerdp /u:vagrant /p:vagrant /v:192.168.122.14:3389 /scale-desktop:300 /f
    ```

    **Note:** *I'm running Fedora on a high-DPI device, so `/scale-desktop:300 /f` will scale the remote Windows desktop to a readable level.

3. You can also use the Gnome Connections app, although this appears to lack a CLI option (wtf?!)

## Bonus steps
We can automatically provision the Vagrant box with RDP enabled and the firewall open:

```ruby
$ cat Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

# enable RDP on the Vagrant box
$cloudinit = <<'EOF'
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
EOF

Vagrant.configure("2") do |config|
  config.vm.box = "jborean93/WindowsServer2022"
  config.vm.provision "shell", inline: $cloudinit
end
```

We can parse the output of `vagrant winrm-config` to set environment variables for the connection. 

This would be useful, for example, in a CI pipeline where you wouldn't want a username, password or other potentially sensitive information exposed. This could be wrapped in a simple shell function, and/or hooked into `direnv` `.envrc` configuration to trigger variable auto-refresh when switching into the Vagrant box's directory. 

```shell
$ eval $(vagrant winrm-config | awk '$1 ~ /^RDP/ { var=toupper($1); gsub(/\r/, "", $2); print var "=\"" $2 "\"" }')
$ wlfreerdp /u:${RDPUSER} /p:${RDPPASSWORD} /v:${RDPHOSTNAME} /scale-desktop:300 /f
```

## Further reading
- [How to enable Remote Desktop from PowerShell on Windows 10](https://pureinfotech.com/enable-remote-desktop-powershell-windows-10/)
- [Vagrant Shell Provisioner](https://developer.hashicorp.com/vagrant/docs/provisioning/shell)
