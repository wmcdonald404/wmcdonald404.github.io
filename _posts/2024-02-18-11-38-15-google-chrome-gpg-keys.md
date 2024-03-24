---
title: "Google Chrome fails GPG checks for DNF update"
date: 2024-02-18 11:41:00
tags:
- linux
- fedora
- chrome
---

## Problem
DNF upgrades fail because Chrome package GPG key validation fails.

When doing a `dnf update` you see a failure similar to:
```
google-chrome                      74 kB/s |  16 kB     00:00    
GPG key at https://dl.google.com/linux/linux_signing_key.pub (0x7FAC5991) is already installed
GPG key at https://dl.google.com/linux/linux_signing_key.pub (0xD38B4796) is already installed
The GPG keys listed for the "google-chrome" repository are already installed but they are not correct for this package.
Check that the correct key URLs are configured for this repository.. Failing package is: google-chrome-stable-121.0.6167.184-1.x86_64
 GPG Keys are configured as: https://dl.google.com/linux/linux_signing_key.pub
The downloaded packages were saved in cache until the next successful transaction.
You can remove cached packages by executing 'dnf clean packages'.
Error: GPG check FAILED
```

## Cause
The Google Chrome package drops a cron config stub into `/etc/cron.daily/google-chrome`, this stub runs once per-day to update the Google GPG keys. You can see this relationship with:
```
root@fedora:~# rpm -ql google-chrome-stable | grep cron
/etc/cron.daily/google-chrome

root@fedora:~# rpm -qf /etc/cron.daily/google-chrome 
google-chrome-stable-121.0.6167.184-1.x86_64
```

If newer packages are signed and published upstream in the window before the cron stub runs, any GPG key validation for these newer packages can fail if new signing keys have been issued.

## Solution
Simply run the cron config stub from `/etc/cron.daily/google-chrome` then re-run the `dnf update`:
```
root@fedora:~#  /etc/cron.daily/google-chrome 
warning: Certificate A040830F7FAC5991:
  Policy rejects subkey 4F30B6B4C07CB649: Policy rejected asymmetric algorithm
warning: Certificate 7721F63BD38B4796:
  Subkey 1397BC53640DB551 is expired: The subkey is not live
  Subkey 78BD65473CB3BD13 is expired: The subkey is not live
  Subkey 6494C6D6997C215E is expired: The subkey is not live
root@fedora:~# dnf update -y
```

## Further reading
- https://lists.fedoraproject.org/archives/list/users@lists.fedoraproject.org/thread/SHIT2FL467SJYNRBK3H7VFDFLUPNZTZN/
