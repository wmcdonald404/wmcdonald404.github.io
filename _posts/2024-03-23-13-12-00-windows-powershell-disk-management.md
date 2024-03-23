---
title: "Windows - Powershell - Discovering, Formatting and Attaching Disks"
date: 2024-03-23 13:12:00
---

## Overview
When automating provisioning of Windows systems, it might be useful to be able to list, format and mount (or attach) block devices using Powershell to streamline an end-to-end deployment process.

## Preparation
Now we have:
1. [Vagrant set up to run under Libvirt on Fedora](https://wmcdonald404.github.io/github-pages/2024/03/20/18-51-00-linux-vagrant-libvirt-on-fedora.html)
2. [A Windows Vagrant box ready to run](https://wmcdonald404.github.io/github-pages/2024/03/22/22-44-00-linux-vagrant-windows-boxes.html)

We can get ready to discover disks, format, attach, label etc.

1. Vagrant up the box:
```
$ cd ~/working/vagrant/windows-scratch
$ vagrant up
```

2. Connect to the instance, invoke Powershell:
```
$ vagrant ssh
vagrant@192.168.121.8's password: <default vagrant password: vagrant>
vagrant@WIN-JSJO34QHSE7 C:\Users\vagrant> pwsh
PS C:\Users\vagrant> 
```

## How-to

1. First, list all the attached block devices:
```
PS> Get-Disk
```

2. Check the members in the collection:
```
PS> Get-Disk
```

3. Filter this list to a subset of useful properties:
```
PS> Get-Disk | Select-Object Number, HealthStatus, OperationalStatus, Size
Number HealthStatus OperationalStatus        Size
------ ------------ -----------------        ----
     1 Healthy      Offline            2000000000
     0 Healthy      Online            42949672960
     3 Healthy      Offline            2000000000
     4 Healthy      Offline            2000000000
     2 Healthy      Offline            2000000000
```

3. Return the same output with better formatting on the Size column:
```
PS> Get-Disk | Select-Object Number, HealthStatus, OperationalStatus, @{N="Size";E={$_.Size / 1024 / 1024 / 1024 }}
```
Or alternatively:
```
PS C:\Users\vagrant> Get-Disk | Sort-Object Number | Select-Object Number, HealthStatus, OperationalStatus, @{N="Size (GB)";E={[Math]::Round($_.Size/1GB,3)}}
Number HealthStatus OperationalStatus Size (GB)
------ ------------ ----------------- ---------
     0 Healthy      Online                40.00
     1 Healthy      Online                 1.86
     2 Healthy      Offline                1.86
     3 Healthy      Offline                1.86
     4 Healthy      Offline                1.86
```

4. Initialise a disk with a GPT partition, and format the volume:
```
PS> Initialize-Disk -Number 1 -PartitionStyle GPT
PS> New-Volume -DiskNumber 1 -FriendlyName DATA1 -FileSystem NTFS
PS> Add-PartitionAccessPath -DiskNumber 1 -PartitionNumber 2 -AccessPath D:
```

5. We could achieve a similar result in a single pass with:
```
Get-Disk | Where-Object OperationalStatus -eq 'Offline'|
    Initialize-Disk -PartitionStyle GPT -PassThru |
    New-Volume -FileSystem NTFS -DriveLetter F -FriendlyName 'New-Volume'
```

6. And we can examine the resulting disk layout with:
```
PS C:\Users\vagrant> Get-Partition | Select-Object DiskNumber, PartitionNumber,  DriveLetter, GptType, @{N="Size (GB)";E={[Math]::Round($_.Size/1GB,1)}} | Format-Table         
DiskNumber PartitionNumber DriveLetter GptType                                Size (GB)
---------- --------------- ----------- -------                                ---------
         1               1            {e3c9e316-0b5c-4db8-817d-f92df00215ae}      0.00
         1               2           D {ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}      1.80
         0               1                                                        0.30
         0               2           C                                            39.70
```

## Shutdown
Once familiar with disk discovery, formatting we can exit and shutdown:

```
PS C:\Users\vagrant> exit
vagrant@WIN-JSJO34QHSE7 C:\Users\vagrant> exit
$ vagrant halt
$ vagrant destroy
```

## Next steps
Experiment resizing disks transparently at the hypervisor layer then extending the volume and filesystem online over the top.

## Further reading
- https://learn.microsoft.com/en-us/powershell/module/storage/?view=windowsserver2022-ps
- [Get-Disk](https://learn.microsoft.com/en-us/powershell/module/storage/get-disk?view=windowsserver2022-ps) 
- [Initialise-Disk](https://learn.microsoft.com/en-us/powershell/module/storage/initialize-disk?view=windowsserver2022-ps)
- [Format-Volume](https://learn.microsoft.com/en-us/powershell/module/storage/format-volume?view=windowsserver2022-ps)
- [Add-PartitionAccessPath](https://learn.microsoft.com/en-us/powershell/module/storage/add-partitionaccesspath?view=windowsserver2022-ps)
