---
title: "Powershell History, Functions and Aliases"
date: 2024-03-10 13-21-59
---

## Overview
This post outlines some basic Powershell behaviour around history, functions and aliases.

## Powershell History
The Powershell `history` command (also aliased to `h`) is an alias to the `Get-History` cmdlet. This returns useful history information but only for the current session.

`Get-PSReadLineOption` will return a list of options for Powershell readline behaviour.

To retreive history across all Powershell sessions `(Get-PSReadLineOption).HistorySavePath` will return the path to the history file commonly used access multiple sessions:

```
PS> (Get-PSReadLineOption).HistorySavePath
/home/wmcdonald/.local/share/powershell/PSReadLine/ConsoleHost_history.txt
```
The path can be searched using `Select-String` (or its alias `sls`) as follows:
```
PS> sls <searchstring> (Get-PSReadLineOption).HistorySavePath
```
## Powershell Functions
On Windows systems, Powershell functions can be dropped into a file called `Microsoft.PowerShell_Profile.ps1` under `C:\Users\<username>\Documents\WindowsPowerShell\` where they will be sourced into the shell on startup.

For example:
```
function vpnstate {
    Get-Process -name vpnui 
    &"C:\Program Files(x64)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe" state
}
function vpnup {
    Get-Process -name vpnui | Stop-Process
    &"C:\Program Files(x64)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe" connect VPN-PROFILE-NAME
}
function vpndown {
    &"C:\Program Files(x64)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe" disconnect 
}
```

## Powershell Aliases
`Get-Alias` lists all current aliases set in the environment.
`New-Alias` will create a new alias if one does not exist, or error if an alias exists.
`Set-Alias` will create a new alias, or update an existing alias.

As with Functions earlier, Aliases can be added to Profiles in order to ensure they're loaded  into an environment.

## Further reading
### History
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_history?view=powershell-7.4
- https://stackoverflow.com/questions/44104043/how-can-i-see-the-command-history-across-all-powershell-sessions-in-windows-serv
### Profiles
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.4
### Aliases
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.4
- https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
- https://stackoverflow.com/questions/48093565/whats-the-difference-between-powershells-new-alias-and-set-alias-cmdlets