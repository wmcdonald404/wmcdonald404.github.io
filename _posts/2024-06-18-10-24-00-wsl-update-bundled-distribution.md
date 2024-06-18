---
title: Update a Distribution in WSL
date: 2024-06-18 10:24:00
tags:
- windows
- wsl
- linux
- ubuntu
---

## Overview
In this post, we'll cover the process to update an existing distribution as bundled by Microsoft.

## Background
For WSL2 distributions managed by Microsoft, you can simply pull down the latest bundled distro when you need it and it's made available. So for example, if Ubuntu 22.04 was the latest release when WSL2 was initially installed, months later 24.04 is released and we'd like to add that later release to our choice of distributions.

## How-to

### Windows
On your Windows system:

1. Check for updates to WSL:
    ```
    PS C:\Users\wmcdonald> wsl --update
    Checking for updates.
    The most recent version of Windows Subsystem for Linux is already installed.
    ```

2. Verify your current installed WSL distribution(s):
    ```
    PS C:\Users\wmcdonald> wsl -l -v
    NAME                   STATE           VERSION
    * docker-desktop-data    Stopped         2
    Fedora-40              Stopped         2
    Fedora-38              Stopped         2
    Ubuntu-22.04           Running         2
    docker-desktop         Stopped         2
    ```

3. Check which distributions are available online from the vendor:
    ```
    PS C:\Users\wmcdonald> wsl --list --online
    The following is a list of valid distributions that can be installed.
    Install using 'wsl.exe --install <Distro>'.

    NAME                                   FRIENDLY NAME
    Ubuntu                                 Ubuntu
    Debian                                 Debian GNU/Linux
    kali-linux                             Kali Linux Rolling
    Ubuntu-18.04                           Ubuntu 18.04 LTS
    Ubuntu-20.04                           Ubuntu 20.04 LTS
    Ubuntu-22.04                           Ubuntu 22.04 LTS
    Ubuntu-24.04                           Ubuntu 24.04 LTS
    OracleLinux_7_9                        Oracle Linux 7.9
    OracleLinux_8_7                        Oracle Linux 8.7
    OracleLinux_9_1                        Oracle Linux 9.1
    openSUSE-Leap-15.5                     openSUSE Leap 15.5
    SUSE-Linux-Enterprise-Server-15-SP4    SUSE Linux Enterprise Server 15 SP4
    SUSE-Linux-Enterprise-15-SP5           SUSE Linux Enterprise 15 SP5
    openSUSE-Tumbleweed                    openSUSE Tumbleweed
    ```

3. Install the later distro:
    ```
    PS C:\Users\wmcdonald> wsl --install -d Ubuntu-24.04
    Installing: Ubuntu 24.04 LTS
    Ubuntu 24.04 LTS has been installed.
    Launching Ubuntu 24.04 LTS...
    Installing, this may take a few minutes...
    Please create a default UNIX user account. The username does not need to match your Windows username.
    For more information visit: https://aka.ms/wslusers
    Enter new UNIX username: wmcdonald
    New password:
    Retype new password:
    passwd: password updated successfully
    Installation successful!
    To run a command as administrator (user "root"), use "sudo <command>".
    See "man sudo_root" for details.

    Welcome to Ubuntu 24.04 LTS (GNU/Linux 5.15.153.1-microsoft-standard-WSL2 x86_64)

    * Documentation:  https://help.ubuntu.com
    * Management:     https://landscape.canonical.com
    * Support:        https://ubuntu.com/pro

    System information as of Tue Jun 18 11:38:05 BST 2024

    System load:  0.08                Processes:             74
    Usage of /:   0.1% of 1006.85GB   Users logged in:       0
    Memory usage: 2%                  IPv4 address for eth0: 172.19.69.123
    Swap usage:   0%


    This message is shown once a day. To disable it please create the
    /home/wmcdonald/.hushlogin file.
    ```

4. Now review the list of installed distros again:

    ```
    PS C:\Users\wmcdonald> wsl -l -v
    NAME                   STATE           VERSION
    * docker-desktop-data    Stopped         2
      Ubuntu-24.04           Stopped         2
      Fedora-40              Stopped         2
      Fedora-38              Stopped         2
      Ubuntu-22.04           Running         2
      docker-desktop         Stopped         2
    ```

    *Note:* Restart the Windows Terminal and a new profile matching the added distribution should appear.

## Further reading
- [Upgrade Ubuntu in WSL2 from 20.04 to 22.04](https://askubuntu.com/questions/1428423/upgrade-ubuntu-in-wsl2-from-20-04-to-22-04)
- [Change the default Linux distribution installed](https://learn.microsoft.com/en-us/windows/wsl/install#change-the-default-linux-distribution-installed)