---
title: "Quick Active Directory Controller - (WIP)"
tags:
- windows
- active-directory
- powershell
- vagrant
---

# Overview

Years ago I had to build some quick-and-dirty Active Directory (AD) infrastructure in a virtualised lab in order to reproduce some cross-domain trusts and Red Hat Identity Manager integration.

This post will cover the basic steps to provision an Active Direcory Domain Controller. 

We'll use [Windows 2022 on Vagrant with the Libvirt Provider](https://wmcdonald404.github.io/github-pages/2024/03/20/linux-vagrant-windows-boxes.html) as our starting point to update the end-to-end process. (Last time I built this was on Windows Server 2016 on VMware.)

# Provision 

1. Start a Windows 2022 Vagrant Box
    ```
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant up
    ```

2. Connect to the Vagrant Box and start Powershell
    ```
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant ssh
    vagrant@WIN-Q5TRJJGJS2J C:\Users\vagrant>pwsh
    PS C:\Users\vagrant> 
    ```

    > **Note #1:** default password: `vagrant`

    > **Note #2:** This step will be required after any restarts or reconnection.

3. Rename the VM
    ```
    PS C:\Users\vagrant> Rename-Computer -NewName ad01
    WARNING: The changes will take effect after you restart the computer WIN-Q5TRJJGJS2J.
    PS C:\Users\vagrant> Restart-Computer
    PS C:\Users\vagrant> client_loop: send disconnect: Broken pipe
    <... wait a few seconds...>
    ```

4. Reconnect, invoke Powershell, verify the hostname change:
    ```
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant ssh
    vagrant@WIN-Q5TRJJGJS2J C:\Users\vagrant>pwsh
    PS C:\Users\vagrant> $Env:COMPUTERNAME
    AD01
    ```

5. Configure time sync:
    ``` 
    PS C:\Users\vagrant> w32tm /config /manualpeerlist:pool.ntp.org /syncfromflags:MANUAL
    The command completed successfully.
    PS C:\Users\vagrant> Stop-Service w32time
    PS C:\Users\vagrant> Start-Service w32time
    PS C:\Users\vagrant> w32tm /query /status
    Leap Indicator: 3(not synchronized)
    Stratum: 0 (unspecified)
    Precision: -23 (119.209ns per tick)
    Root Delay: 0.0000000s
    Root Dispersion: 0.0000000s
    ReferenceId: 0x00000000 (unspecified)
    Last Successful Sync Time: unspecified
    Source: Local CMOS Clock
    Poll Interval: 6 (64s)
    ```

    > **Note:** for a pure Powershell equivalent:

    ```
    Push-Location
    Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers
    Set-ItemProperty . 0 "ca.pool.ntp.org"
    Set-ItemProperty . "(Default)" "0"
    Set-Location HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters
    Set-ItemProperty . NtpServer "ca.pool.ntp.org"
    Pop-Location
    Stop-Service w32time
    Start-Service w32time
    ```

6. Create the domain controller
    ```
    #
    # Windows PowerShell script for AD DS Deployment
    #
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Import-Module ADDSDeployment
    Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "home.arpa" `
    -DomainNetbiosName "HOME" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
    ```



# Configure

# Persist

# References
- [setting NTP server on Windows machine using PowerShell](https://stackoverflow.com/questions/17507339/setting-ntp-server-on-windows-machine-using-powershell)
- [How to choose a sensible local domain name for a home network?](https://superuser.com/a/1502560)
- [Always choose the right DNS / Active Directory domain name for your 2024 home lab](https://medium.com/@naglafarn/always-choose-the-right-dns-active-directory-domain-name-for-your-2024-home-lab-1d22311ff674)
- [What domain name to use for your home network](https://www.ctrl.blog/entry/homenet-domain-name.html)