---
title: "Powershell History, Functions and Aliases"
date: 2024-03-10 13-21-59
tags:
- microsoft
- powershell
- history
- functions
- aliases
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
## Powershell Profiles
In Powershell, Profiles are scripts that run automatically when the shell starts up. Different profiles can be set at granularity for users and computers.

On Windows systems, Powershell will run the ps1 script (if one exists) at the value defined in `$PROFILE.CurrentUserCurrentHost`. On a normal Windows system this would be `Microsoft.PowerShell_Profile.ps1` under `C:\Users\<username>\Documents\WindowsPowerShell\` where they will be sourced into the shell on startup. 

The Linux equivalent value for `$PROFILE.CurrentUserCurrentHost` would be `/home/<username>/.config/powershell/Microsoft.PowerShell_profile.ps1`

`$PROFILE` is an automatic variable which includes the paths to profiles for the various levels of granularity. It can be explored by enumeration as shown:

```
PS> $PROFILE | Get-Member -Type All

   TypeName: System.String

Name                   MemberType            Definition
----                   ----------            ----------
Clone                  Method                System.Object Clone(), System.Object ICloneable.Clone()
CompareTo              Method                int CompareTo(System.Object value), int CompareTo(string strB), int IComparable.CompareTo(System.Object obj), i…
<output truncated>
```

Examine the specific granular properties on the object:
```
PS /home/wmcdonald> $PROFILE | Get-Member -Type NoteProperty

   TypeName: System.String

Name                   MemberType   Definition
----                   ----------   ----------
AllUsersAllHosts       NoteProperty string AllUsersAllHosts=/opt/microsoft/powershell/7/profile.ps1
AllUsersCurrentHost    NoteProperty string AllUsersCurrentHost=/opt/microsoft/powershell/7/Microsoft.PowerShell_profile.ps1
CurrentUserAllHosts    NoteProperty string CurrentUserAllHosts=/home/wmcdonald/.config/powershell/profile.ps1
CurrentUserCurrentHost NoteProperty string CurrentUserCurrentHost=/home/wmcdonald/.config/powershell/Microsoft.PowerShell_profile.ps1
```

With this information, functions (or aliases) can be dropped into a file at `$PROFILE.CurrentUserCurrentHost` and would be available in the shell at startup:

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
- https://thesmashy.medium.com/helpful-functions-for-your-powershell-profile-9fece679f4d6
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.4
### Aliases
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_aliases?view=powershell-7.4
- https://stackoverflow.com/questions/24914589/how-to-create-permanent-powershell-aliases
- https://stackoverflow.com/questions/48093565/whats-the-difference-between-powershells-new-alias-and-set-alias-cmdlets
