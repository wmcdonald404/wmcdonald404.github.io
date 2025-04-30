---
title: "Quicker Windows Active Directory Controller"
tags:
- windows
- active-directory
- dns
- kerberos
- powershell
- vagrant
---

* TOC
{:toc}

# Overview

Following on from [Quick Active Directory Controller](https://wmcdonald404.co.uk/2024/11/09/quick-active-directory-controller.html), wrapped the bare minimum steps into some Powershell to create a quicker, more automated Vagrant box Active Directory (AD) controller.

Cloning the respository and making any tweaks required for your specific Vagrant provider are assumed...

# Steps
Provision Virtual Machine / Vagrant Box 

1. Start the Windows 2022 Vagrant Box
    ```shell
    $ cd repos/wmcdonald404/vagrantfiles/jborean93/windows2022-addc/
    $ vagrant up    
    ```

2. Once the machine's up, we can 

    a. Run ad-hoc commands:
    
    ```shell
    $ vagrant winrm -c hostname
    WIN-ODH49KSMJL3
    $ vagrant winrm -c "(get-addomain).PDCEmulator"
    WIN-ODH49KSMJL3.WIN.ODH49KSMJL3
    ```
    
    b. connect via its console:
    
    ```shell
    $ vagrant ssh
    vagrant@WIN-Q5TRJJGJS2J C:\Users\vagrant>pwsh
    PS C:\Users\vagrant> 
    ```

    > **Note:** default password: `vagrant`

    c. RDP...

    ```
    $ eval $(vagrant winrm-config | awk '$1 ~ /^RDP/ { var=toupper($1); gsub(/\r/, "", $2); print var "=\"" $2 "\"" }')
    $ wlfreerdp /u:${RDPUSER} /p:${RDPPASSWORD} /v:${RDPHOSTNAME} /scale-desktop:300 /f
    ```

# References

