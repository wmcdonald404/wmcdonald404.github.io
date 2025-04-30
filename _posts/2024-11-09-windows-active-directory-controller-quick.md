---
title: "Quick Windows Active Directory Controller"
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

Years ago I had to build some quick-and-dirty Active Directory (AD) infrastructure in a virtualised lab in order to reproduce some cross-domain trusts and Red Hat Identity Manager integration.

This post will cover the basic steps to provision an AD Domain Controller. 

We'll use [Windows 2022 on Vagrant with the Libvirt Provider](https://wmcdonald404.github.io/github-pages/2024/03/20/linux-vagrant-windows-boxes.html) as our starting point to update the end-to-end process. (Last time I built this was on Windows Server 2016 on VMware.)

# Steps
## Provision Virtual Machine / Vagrant Box 

1. Start a Windows 2022 Vagrant Box
    ```shell
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant up
    ```

2. Connect to the Vagrant Box and start Powershell
    ```shell
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant ssh
    vagrant@WIN-Q5TRJJGJS2J C:\Users\vagrant>pwsh
    PS C:\Users\vagrant> 
    ```

    > **Note #1:** default password: `vagrant`

    > **Note #2:** This step will be required after any restarts or reconnection.

3. Rename the VM
    ```powershell
    PS C:\Users\vagrant> Rename-Computer -NewName ad01
    WARNING: The changes will take effect after you restart the computer WIN-Q5TRJJGJS2J.
    PS C:\Users\vagrant> Restart-Computer
    PS C:\Users\vagrant> client_loop: send disconnect: Broken pipe
    <... wait a few seconds...>
    ```

4. Reconnect, invoke Powershell, verify the hostname change:
    ```shell
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant ssh
    vagrant@WIN-Q5TRJJGJS2J C:\Users\vagrant>pwsh
    PS C:\Users\vagrant> $Env:COMPUTERNAME
    AD01
    ```

5. Configure time sync:
    ```powershell
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

    ```powershell
    Set-Location HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers
    Set-ItemProperty . 0 "ca.pool.ntp.org"
    Set-ItemProperty . "(Default)" "0"
    Set-Location HKLM:\SYSTEM\CurrentControlSet\services\W32Time\Parameters
    Set-ItemProperty . NtpServer "ca.pool.ntp.org"
    Set-Location 
    Stop-Service w32time
    Start-Service w32time
    ```

## Configure Active Directory Domain

6. Create the domain controller
    ```powershell
    # Set our domain/subdomain
    # $Domain.Split('.')[0].ToUpper() will return 'NOSTROMO' for the NetBIOS domain name
    
    $Domain = 'nostromo.com'
    
    # Windows PowerShell script for AD DS Deployment
    
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Import-Module ADDSDeployment
    Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName $Domain `
    -DomainNetbiosName $Domain.Split('.')[0].ToUpper() `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -Force:$true
    ```

7. Add a suitably complex password (`vagrant` will not cut the mustard):
    ```powershell
    WARNING: A script or application on the remote computer LOCALHOST is sending a prompt request. When you are prompted, enter sensitive information, such as credentials or passwords, only if you trust the remote computer and the application or script that is requesting the data.
    SafeModeAdministratorPassword: *********************
    WARNING: A script or application on the remote computer LOCALHOST is sending a prompt request. When you are prompted, enter sensitive information, such as credentials or passwords, only if you trust the remote computer and the application or script that is requesting the data.
    Confirm SafeModeAdministratorPassword: *********************
    ```

8. Wait for the system to reboot, then reconnect
    ```shell
    [wmcdonald@fedora windows2022 (main ✓)]$ vagrant ssh
    vagrant@192.168.121.218's password: 

    Microsoft Windows [Version 10.0.20348.2031]
    (c) Microsoft Corporation. All rights reserved.

    home\vagrant@AD01 C:\Users\vagrant>pwsh      
    PowerShell 7.3.8

    A new PowerShell stable release is available: v7.4.6 
    Upgrade now, or check out the release page at:       
        https://aka.ms/PowerShell-Release?tag=v7.4.6       

    PS C:\Users\vagrant> 
    ```

9. Validate running services
    ```powershell
    PS C:\Users\vagrant> Get-Service adws,kdc,netlogon,dns

    Status   Name               DisplayName
    ------   ----               -----------
    Running  adws               Active Directory Web Services
    Running  dns                DNS Server
    Running  kdc                Kerberos Key Distribution Center
    Running  Netlogon           netlogon
    ```

10. Validate DNS (note we're still on a DHCP IP address at this stage where previously we'd have switched to a fixed assigned address):
    ```powershell
    PS C:\Users\vagrant> Get-NetIPAddress -AddressFamily IPv4 | Select-Object InterfaceIndex, InterfaceAlias,  IPAddress

    InterfaceIndex InterfaceAlias              IPAddress
    -------------- --------------              ---------
                4 Ethernet Instance 0         192.168.121.218
                1 Loopback Pseudo-Interface 1 127.0.0.1

    PS C:\Users\vagrant> Resolve-DnsName ad01

    Name                                           Type   TTL   Section    IPAddress
    ----                                           ----   ---   -------    ---------
    ad01.nostromo.com                                 AAAA   1200  Question   fe80::d38b:106c:c73a:21b3
    ad01.nostromo.com                                 A      1200  Question   192.168.121.218

    PS C:\Users\vagrant> Resolve-DnsName ad01.nostromo.com

    Name                                           Type   TTL   Section    IPAddress
    ----                                           ----   ---   -------    ---------
    ad01.nostromo.com                                 AAAA   1200  Question   fe80::d38b:106c:c73a:21b3
    ad01.nostromo.com                                 A      1200  Question   192.168.121.218
    ```

## Configure Users and Security Groups
Active Directory Security Groups can be used to group domain users with similar roles, departments, organisational responsibilities or to reflect other organisational concerns. Permissions can then be assigned at the group level, reducing the management overhead as users join, change role or department, or leave.

Create domain security groups, domain users and assign those users to the groups. 

1. Create Security Groups

    - Officers
        ```powershell
        PS> New-ADGroup -Name "Officers" -SamAccountName Officers -GroupCategory Security -GroupScope Global -DisplayName "Bridge Officers" -Path "CN=Users,DC=Nostromo,DC=Com" -Description "Members of Bridge Officers"
        ```

    - Engineering
        ```powershell
        PS> New-ADGroup -Name "Engineers" -SamAccountName Engineers -GroupCategory Security -GroupScope Global -DisplayName "Engineering Crew" -Path "CN=Users,DC=Nostromo,DC=Com" -Description "Members of Engineering Crew"
        ```

    - Pest Control
        ```powershell
        PS> New-ADGroup -Name "Cats" -SamAccountName Cats -GroupCategory Security -GroupScope Global -DisplayName "Pest Control" -Path "CN=Users,DC=Nostromo,DC=Com" -Description "Members of Pest Control Crew"
        ```

2. Create Users

    - Dallas, Officers
        ```powershell
        PS> $Attributes = @{
            Enabled = $true
            ChangePasswordAtLogon = $false
            UserPrincipalName = "dallas@nostromo.com"
            Name = "dallas"
            GivenName = "Captain"
            Surname = "Dallas"
            DisplayName = "Captain Dallas"
            Office = "Bridge"
            AccountPassword = "Thatfigures." | ConvertTo-SecureString -AsPlainText -Force
        }
        PS> New-ADUser @Attributes
        ```
    - Kane & Parker, engineering crew
        ```powershell
        PS> $Attributes = @{
            Enabled = $true
            ChangePasswordAtLogon = $false
            UserPrincipalName = "kane@nostromo.com"
            Name = "kane"
            GivenName = "XO"
            Surname = "Kane"
            DisplayName = "XO Kane"
            Office = "Bridge"
            AccountPassword = "Sillyquestion?" | ConvertTo-SecureString -AsPlainText -Force
        }
        PS> New-ADUser @Attributes
        
        PS> $Attributes = @{
            Enabled = $true
            ChangePasswordAtLogon = $false
            UserPrincipalName = "parker@nostromo.com"
            Name = "parker"
            GivenName = "Chief"
            Surname = "Parker"
            DisplayName = "Chief Parker"
            Office = "Engineering"
            AccountPassword = "Howyadoin?" | ConvertTo-SecureString -AsPlainText -Force
        }
        PS> New-ADUser @Attributes
        ```

    - Jones, Pest Control crew

        ```powershell
        PS> $Attributes = @{
            Enabled = $true
            ChangePasswordAtLogon = $false
            UserPrincipalName = "jones@nostromo.com"
            Name = "jones"
            GivenName = "Jones"
            Surname = "the Cat"
            DisplayName = "Jones the Cat"
            Office = "Everywhere"
            AccountPassword = "Tunaplz?" | ConvertTo-SecureString -AsPlainText -Force
        }
        PS> New-ADUser @Attributes
        ```

3. Add Users to Security Groups
    ```powershell
    PS> Add-ADGroupMember -Identity Officers -Members dallas, kane
    PS> Add-ADGroupMember -Identity Engineers -Members parker
    PS> Add-ADGroupMember -Identity Cats -Members jones
    ```

## Add DNS Records
This is an optional step. If we were delegating a subdomain of the DNS hierarchy to another subsystem. For example these steps would originally have delegated a leaf of the DNS hierarch to Red Hat's Identity Management infrastructure.

1. Add delegation for idm.nostromo.com
    ```powershell
    PS> Add-DnsServerZoneDelegation -Name "nostromo.com" -ChildZoneName "idm" -NameServer "idm01.idm.nostromo.com" -IPAddress 192.168.0.22 -PassThru -Verbose
    ```

## Cross-forest Trust
Again, optional but if we wanted to establish a Trust from one AD domain to another:

```powershell
$localforest = [System.DirectoryServices.ActiveDirectory.Forest]::getCurrentForest()
$strRemoteForest = ‘example.cloud’
$strRemoteUser = ‘administrator’
$strRemotePassword = Read-Host -Prompt “Enter $strRemoteUser password for $strRemoteForest”
$remoteContext = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext(‘Forest’, $strRemoteForest,$strRemoteUser,$strRemotePassword)
$remoteForest = [System.DirectoryServices.ActiveDirectory.Forest]::getForest($remoteContext)
$localForest.CreateTrustRelationship($remoteForest,’Bidirectional’)
```

# Persist
Right now our configuration is limited to a single Vagrant Box. This will persist across reboot of the Vagrant Box until we `vagrant destroy` but a better mechanism may be to externalise the configuration and apply via a provisioner. This will have the added advantage of allowing multiple controllers for different domains to be spun up, allowing us to test cross-domain and cross-forest trusts.


# References
- [setting NTP server on Windows machine using PowerShell](https://stackoverflow.com/questions/17507339/setting-ntp-server-on-windows-machine-using-powershell)
- [How to choose a sensible local domain name for a home network?](https://superuser.com/a/1502560)
- [Always choose the right DNS / Active Directory domain name for your 2024 home lab](https://medium.com/@naglafarn/always-choose-the-right-dns-active-directory-domain-name-for-your-2024-home-lab-1d22311ff674)
- [What domain name to use for your home network](https://www.ctrl.blog/entry/homenet-domain-name.html)
- [ DEF CON 32 - Winning the Game of Active Directory - Brandon Colley ](https://www.youtube.com/watch?v=M-2d3sM3I2o)
- [ Game Of Active Directory ](https://orange-cyberdefense.github.io/GOAD/#)
- [Orange-Cyberdefense/GOAD](https://github.com/Orange-Cyberdefense/GOAD)
- [Naming conventions in Active Directory for computers, domains, sites, and OUs - Table of reserved words](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/naming-conventions-for-computer-domain-site-ou#table-of-reserved-words)