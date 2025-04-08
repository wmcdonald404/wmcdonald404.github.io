---
title: "Configure the AWS CLI with an SSO profile"
tags:
- amazon
- aws
- awscli
- cli
---

## Overview
This is a simple how-to on setting up the AWS CLI for a simple, single AWS organisation, account and IAM role profile.

I'll cover multiple organisations, SSO profiles, accounts and roles in a subsequent article but this is a solid single starting point.

## Background
To quote chaper-and-verse from the AWS documentation:

> The AWS Command Line Interface (AWS CLI) is a unified tool to manage your AWS services. With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts.

Having the CLI to-hand can streamline an engineer's workflow, reducing context switching from the development environment or terminal to the AWS management console UI.

## How-to
1. Install the CLI

    There are a [number of installation options available](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), however when using a distribution with a mature but up-to-date package ecosystem, it can be as simple as installing from the package manager.

    ```shell
    wmcdonald@fedora:~$ sudo dnf info awscli2
    Last metadata expiration check: 0:00:23 ago on Wed 21 Feb 2024 15:44:01 GMT.
    Installed Packages
    Name         : awscli2
    Version      : 2.15.2
    Release      : 1.fc39
    Architecture : noarch
    Size         : 103 M
    Source       : awscli2-2.15.2-1.fc39.src.rpm
    Repository   : @System
    From repo    : updates
    Summary      : Universal Command Line Environment for AWS, version 2
    URL          : https://github.com/aws/aws-cli/tree/v2
    License      : Apache-2.0 AND MIT
    Description  : This package provides version 2 of the unified command line
                 : interface to Amazon Web Services.

    wmcdonald@fedora:~$ sudo dnf -y install awscli2
    ```

2. Validate that the AWS CLI is installed and runs

    ```shell
    wmcdonald@fedora:~$ aws
    
    usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
    To see help text, you can run:

    aws help
    aws <command> help
    aws <command> <subcommand> help

    aws: error: the following arguments are required: command
    ```

3. Configure an SSO session:

    ```shell
    wmcdonald@fedora:~$ aws configure sso-session 
    SSO session name: awssso.home
    SSO start URL [None]: https://a-123abc456sdf.awsapps.com/start/
    SSO region [None]: eu-west-1
    SSO registration scopes [sso:account:access]:

    Completed configuring SSO session: awssso.home
    Run the following to login and refresh access token for this session:
    ```
    
    **Note:** it's possible to create the SSO session definition and the AWS account profile in a single pass. We create them one after the other just to make it clear that a single SSO session definition can be used for more than one AWS account profile.

4. Review the SSO session entry created in `~/.aws/config`:

    ```shell
    wmcdonald@fedora:~$  cat .aws/config 
    [sso-session awssso.home]
    sso_start_url = https://a-123abc456sdf.awsapps.com/start/
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access
    ```

5. Review the SSO session entry created in `~/.aws/config`:

    ```shell
    wmcdonald@fedora:~$  cat .aws/config 
    [sso-session awssso.home]
    sso_start_url = https://a-123abc456sdf.awsapps.com/start/
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access
    ```

6. Set a name for the new AWS profile we would like to link to the SSO session:

    ```shell
    wmcdonald@fedora:~$ export AWS_PROFILE=awsprofile.home.poweruser
    ```

    **Note:** I'm using the `awsprofile.location.role` structure deliberately. It may seem overblown but when we move to multiple locations, organisations, accounts and roles we can set fast-switch profile aliases based on the entry name.

7. Configure the values we want to use for the new profile:

    ```shell
    wmcdonald@fedora:~$ aws configure set sso_session awssso.home
    wmcdonald@fedora:~$ aws configure set sso_account_id 123412341234
    wmcdonald@fedora:~$ aws configure set sso_role_name PowerUserAccess
    wmcdonald@fedora:~$ aws configure set region eu-west-1
    ```

8. Validate the contents configured for the new profile:

    ```shell
    wmcdonald@fedora:~$ cat ~/.aws/config
    [profile awsprofile.home.poweruser]
    sso_session = awssso.home
    sso_account_id = 123412341234
    sso_role_name = PowerUserAccess
    region = eu-west-1
    ```

9. Set the `AWS_PROFILE`, then login and validate the session/profile combination:

    ```shell
    $ export AWS_PROFILE=awsprofile.home.poweruser
    $ aws sso login 
    Attempting to automatically open the SSO authorization page in your default browser.
    If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

    Successfully logged into Start URL: https://a-123abc456sdf.awsapps.com/start/
    ```

    ```
    $ aws ec2 describe-instances
    {
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-0694d931cee176e7d",
                    "InstanceId": "i-06170215c6344402c",
                    "InstanceType": "t2.medium",
    ...
    ```

## Summary
We now have the AWS CLI configured with a single AWS SSO session and corresponding profile.

## Further reading
- [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)
- [https://docs.aws.amazon.com/cli/latest/reference/](https://docs.aws.amazon.com/cli/latest/reference/)
- [https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html)
- [https://dev.to/andreasbergstrom/juggling-multiple-aws-cli-profiles-like-a-pro-2h88](https://dev.to/andreasbergstrom/juggling-multiple-aws-cli-profiles-like-a-pro-2h88)
