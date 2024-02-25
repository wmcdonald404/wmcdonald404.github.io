---
title: "OpenSSH Agent on Windows"
date: 2024-02-05 11:32:00
---

## Overview
Describe the steps to create a new password-protected keypair for OpenSSH on Windows, then add the key to the SSH Agent.

## Background
In order to prepare keys and persist the password-protected private key in the SSH agent we must:

1. Create a keypair
2. Start the SSH agent
3. Add the private key to the agent

Then in order to benefit from key-based authentication:

4. Add the public key to target system(s)
5. Test connectivity

## How-to
1. Create the keypair, use `-C` to include a comment and `-f` to designate the file name for the private key.

   For example:
   ```
   PS> ssh-keygen -C <username and date> -f <path-to-file>
   ```

   Or to extract the username, date and path programatically from the environment:
   ```
   PS> $KEY_COMMENT = $(($Env:Username) + "-" + $(Get-Date -format "yyyy-MM-dd"))
   PS> $KEY_PATH = $(($Env:userprofile) + "/.ssh/" + ($Env:UserName) + ".id_rsa")
   PS> ssh-keygen -C $KEY_COMMENT -f $KEY_PATH
   ```

   When prompted for a passphrase, enter a strong password for the private key:
   ```
   Enter passphrase (empty for no passphrase): 
   Enter same passphrase again: 
   ```

2. Start the SSH agent service

    Note: starting the service will require Local Administrator privileges on the target Windows system.
    ```
    PS> Get-Service ssh-agent | Set-Service -StartupType Automatic -PassThru | Start-Service
    ```

3. Add the private key to the SSH agent and verify

    ```
    PS> ssh-add $KEY_PATH
    Enter passphrase for .\.ssh\user.name.id_rsa: *******************
    Identity added: .\.ssh\user.name.id_rsa
    ```

4. Add the public key to a target system

    ```
    ```

5. Test connectivity

    ```
    ```


## Summary


## Further reading
