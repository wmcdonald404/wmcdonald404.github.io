---
title: Duplicate a Distribution in WSL
date: 2024-06-05 12:29:00
layout: default
tags:
- windows
- wsl
- linux
---

## Overview
In this post, we'll cover how to duplicate an existing WSL Linux distrbution.

## Background
For WSL2 distributions managed by Microsoft, you can simply pull down the latest bundled distro when you need it and it's made available.

For distributions you may have hand-rolled or pulled from other locations, you may need to do perform some additional intervention if you want to retain multiple copies of a release. For example I have a Fedora 38 distribution built based on [Install Fedora 37 or earlier on Windows Subsystem for Linux (WSL)](https://dev.to/bowmanjd/install-fedora-on-windows-subsystem-for-linux-wsl-4b26), and at time of writing Fedora 40 is current. I could do an in-place upgrade of F38 -> F40, but I may wish to retain copies of both releases (or any other intermediate upgrade points should I choose).

In order to do this we can follow a process similar to [Duplicate a Linux distro under WSL2](https://fourco.nl/blogs/duplicate-a-linux-distro-under-wsl2/):

1. Clone F38 -> F38.copy
2. Upgrade f38.copy -> F40
3. ...
4. Profit

## How-to

### Windows
On your Windows system:

1. Verify your current installed WSL distribution(s):
    ```
    PS C:\Users\wmcdonald> wsl -l
    Windows Subsystem for Linux Distributions:
    docker-desktop-data (Default)
    Fedora-38
    Ubuntu-22.04
    docker-desktop
    ```
    *Note*: You can identify the underlying disk location of your WSL distributions by running `Get-ChildItem "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss" -Recurse`

2. Create a directory to hold our intermediate distribution image(s):
    ```
    PS C:\Users\wmcdonald> New-Item -Type Directory d:\wsl\distros\
    ```

3. Export a tar archive/image of the target distribution:
    ```
    PS C:\Users\wmcdonald> wsl --export Fedora-38 D:\wsl\distros\Fedora-38.tar
    The operation completed successfully.
    ```

4. Import the distro as a new distribution/profile:
    ```
    PS C:\Users\wmcdonald> wsl --import Fedora-40 C:\Users\wmcdonald\wsl\Fedora-40 D:\wsl\distros\Fedora-38.tar
    Import in progress, this may take a few minutes.
    The operation completed successfully.
    ```
    *Note*: We could just as easily have a single 'Fedora' or 'Fedora-Latest' distro profile which we constantly upgrade in-place if we don't care about the availability of previous releases.

4. We can now start the new distribution:
    ```
    PS C:\Users\wmcdonald> wsl -d Fedora-40 -u wmcdonald
    [wmcdonald@DESKTOP-9HGJE25 wmcdonald]$
    ```

5. Create a new Windows Terminal profile for Fedora-40.

    TODO: Programmatically add the distribution as a new profile in the Windows Terminal.

### WSL
In your WSL2 instance:

1. Now in-place upgrade the distribution from Fedora-38 -> Fedora-40
    ```
    [wmcdonald@DESKTOP-9HGJE25 ~]$ sudo su -
    [root@DESKTOP-9HGJE25 ~]# dnf upgrade -y --refresh
    [root@DESKTOP-9HGJE25 ~]# dnf install dnf-plugin-system-upgrade
    [root@DESKTOP-9HGJE25 ~]# dnf system-upgrade download --releasever=40
    [root@DESKTOP-9HGJE25 ~]# export DNF_SYSTEM_UPGRADE_NO_REBOOT=1
    [root@DESKTOP-9HGJE25 ~]# dnf system-upgrade reboot
    [root@DESKTOP-9HGJE25 ~]# dnf upgrade --refresh
    ```

## Further reading
- [Duplicate a Linux distro under WSL2](https://fourco.nl/blogs/duplicate-a-linux-distro-under-wsl2/)
- [Install Fedora 37 or earlier on Windows Subsystem for Linux (WSL)](https://dev.to/bowmanjd/install-fedora-on-windows-subsystem-for-linux-wsl-4b26)
- [Where is WSL located on my computer?](https://askubuntu.com/a/1380274)
- [How to Upgrade to Fedora 37 In Place on Windows Subsystem for Linux (WSL)](https://dev.to/bowmanjd/how-to-upgrade-fedora-in-place-on-windows-subsystem-for-linux-wsl-oh3)
