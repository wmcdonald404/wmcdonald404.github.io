---
title: "Powershell `basename` and `dirname`"
tags:
- microsoft
- vscode
- terminal
- powershell
---

## Overview

When working in VSCode across multiple repositories, there's no obvious way to switch the integrated terminal's current working directory to match an editor tab you may have open. VSCode does allow copying the full path of the current file but this needs further manipulation before use.


## Background

VSCode provide keyboard shortcuts to copy the relative or absolute path of the current focused file which can then be pasted into the integrated terminal. However, this copies the **full file path**, for example `'d:\repositories\personal\github-pages\_posts\2024-01-02-github-pages-simple-blog.md'`. 

On Unix/Linux systems, it's trivial to `dirname` that full path into something `cd`-able:

* CTRL-ALT-C or CTRL-K P will copy the full path, for example `/home/wmcdonald/repos/personal/github-pages/_posts/2024-06-18-wsl-update-bundled-distribution.md`

```
wmcdonald@fedora:~$ dirname /home/wmcdonald/repos/personal/github-pages/_posts/2024-06-18-wsl-update-bundled-distribution.md
/home/wmcdonald/repos/personal/github-pages/_posts

wmcdonald@fedora:~$ cd $(dirname /home/wmcdonald/repos/personal/github-pages/_posts/2024-06-18-wsl-update-bundled-distribution.md)

wmcdonald@fedora:~/repos/personal/github-pages/_posts$ pwd
/home/wmcdonald/repos/personal/github-pages/_posts
```

On Windows systems, you can use Git-bash to achieve the same fluidity, or you can create some simple Powershell functions to mimic the same behaviour.

## How-to

1. Open your [Powershell profile](https://wmcdonald404.github.io/github-pages/2024/03/10/windows-powershell-history-functions-and-aliases.html#powershell-profiles) to add local Powershell functions (analogous to aliases or functions in bash/zsh)

    ```Powershell
    PS> code $PROFILE
    ```

2. Add the following functions to the `$PROFILE`... file. 

    ```Powershell
    # Unix-like functions (https://stackoverflow.com/a/32634452)

    # returns the file name from a full path:
    function basename {
        Param (
            [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
            [string[]]$FilePath
        )
        return (Get-Item $FilePath).Name
    }

    # returns the directory path from a full path:
    function dirname {
        Param (
            [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
            [string[]]$FilePath
        )
        return (Get-Item $FilePath).DirectoryName
    }

    # switches into directory from a full path: 
    function cdirname {
        Param (
            [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
            [string[]]$FilePath
        )
        return Set-Location (Get-Item $FilePath).DirectoryName
    }
    ```


## Further reading
- [Powershell History, Functions and Aliases (and Profiles)](https://wmcdonald404.github.io/github-pages/2024/03/10/windows-powershell-history-functions-and-aliases.html#powershell-profiles)
- [Stackoverflow - Removing path and extension from filename in PowerShell](https://stackoverflow.com/a/32634452)