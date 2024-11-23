---
title: "Installing the Windows Remote Server Administration Tools (RSAT)"
tags:
- microsoft
- windows
- ad
- active directory
- rsat
---

## Overview
To quote the Microsoft documentation on Remote Server Administration Tools...¬

> Remote Server Administration Tools includes Server Manager, Microsoft Management Console (mmc) snap-ins, consoles, Windows PowerShell cmdlets and providers, and some command-line tools for managing roles and features that run on Windows Server.

## How-to
### Powershell

1. Check which RSAT components, if any, are installed on the target system:
```Powershell
PS> Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName, Name, State
```
2. Either
  a. Install individual components as required
```Powershell
PS> Add-WindowsCapability -Online -Name "<item_name>"
```
  b. Or install all available RSAT features
```Powershell
PS> Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
```

### UI
#### Windows 10
1. Click Start
2. Type "Add an optional feature"
3. Enter
4. Click "Add a feature"
5. Type "RSAT" into "Find an available optional feature"
6. Select the features required
7. Install

## Next steps
Once installed, the additional components will be available as MMC snap-ins or Powershell modules.

## Further reading
- https://learn.microsoft.com/en-us/troubleshoot/windows-server/system-management-components/remote-server-administration-tools
- https://www.pdq.com/blog/how-to-install-remote-server-administration-tools-rsat/
