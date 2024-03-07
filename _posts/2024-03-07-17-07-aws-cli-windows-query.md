---
title: "AWS - CLI - Using the AWS CLI on Windows with Powershell"
date: 2024-03-07 17:07:07
---

## Overview
Building on the lessons from [AWS - Configure the AWS CLI with SSO and multiple profiles](https://wmcdonald404.github.io/github-pages/2024/02/24/13-54-50-aws-cli-configure-with-sso-profiles.html), we can perform similar queries from a Windows machine with the AWS CLI using Powershell to extract similar instance metadata.

## How-to
1. Set the Windows Powershell environment variable for the profile we wish to use:
    ```
    $Env:AWS_PROFILE="dev-account.developer"
    ```
2. Test that the SSO profile has works as expected:
    ```
    PS> aws ec2 describe-instances
    ```
3. Filter the output of `aws ec2 describe-instances`:
    ```
    PS> aws ec2 describe-instances | ConvertFrom-Json | `
    Select-Object -ExpandProperty Reservations | ForEach-Object { $_.Instances | `
    ForEach-Object { $tag = ($_.Tags | Where-Object { $_.Key -eq 'aws:cloud9:owner' }); `
    if ($tag) { [PSCustomObject]@{ "Instance ID" = $_.InstanceId; "Tag aws:cloud9:owner" = $tag.Value; "Instance State" = $_.State.Name } } } }
    ```
4. Review the output:
    ```
    Instance ID         Tag aws:cloud9:owner                 Instance State
    -----------         --------------------                 --------------
    i-034e459b55d574564 A0880D35011EEA187F057:bob.typeytype  stopped
    i-0af34b3e0f9fecc9e A0880D35011EEA187F057:alan.syscall   running
    ```
5. Optionally, start the desired instance and connect via SSH or SSH over SSM:
    ```
    PS> aws ec2 start-instances --instance-ids i-034e459b55d574564 
    ```
## Further reading
- 
- 