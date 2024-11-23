---
title: "Configure the AWS CLI with multiple profiles"
tags:
- amazon
- aws
- awscli
- cli
---

## Overview
Set up the AWS CLI with multiple profiles (for example work, training or personal accounts)

## Background
To quote chaper-and-verse from the AWS documentation:

> The AWS Command Line Interface (AWS CLI) is a unified tool to manage your AWS services. With just one tool to download and configure, you can control multiple AWS services from the command line and automate them through scripts.

Having the CLI to-hand can streamline an engineer's workflow, reducing context switching from the development environment or terminal to the AWS management console UI.

## How-to
1. Install the CLI

    There are a [number of installation options available](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html), however when using a distribution with a mature but up-to-date package ecosystem, it can be as simple as installing from the package manager.

    ```Shell
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

    ```Shell
    wmcdonald@fedora:~$ aws
    
    usage: aws [options] <command> <subcommand> [<subcommand> ...] [parameters]
    To see help text, you can run:

    aws help
    aws <command> help
    aws <command> <subcommand> help

    aws: error: the following arguments are required: command
    ```

3. Configure a personal 'home' profile in the AWS CLI:

    ```Shell
    wmcdonald@fedora:~$ aws configure --profile home
    AWS Access Key ID [None]: <<accesskey>>
    AWS Secret Access Key [None]: <<secretkey>>
    Default region name [None]: eu-west-1
    Default output format [None]: 
    ```

4. Verify that the CLI and profile can retreive data from AWS:

    ```Shell
    wmcdonald@fedora:~$ aws ec2 describe-instances --profile home | jq '.[][].Instances[].InstanceId'
    "i-06170215c6344402c"
    ```

5. Set the current profile in the `AWS_PROFILE` environment variable and re-verify:

    ```Shell
    wmcdonald@fedora:~$ export AWS_PROFILE=home
    wmcdonald@fedora:~$ aws ec2 describe-instances
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

6. Rinse and repeat the profile setup for a 'work' profile in the AWS CLI:

    ```Shell
    wmcdonald@fedora:~$ aws configure --profile work
    AWS Access Key ID [None]: <<workaccesskey>>
    AWS Secret Access Key [None]: <<worksecretkey>>
    Default region name [None]: us-east-1
    Default output format [None]: 
    ```

## Summary
We now have the AWS CLI configured with two profiles and a relatively simple environment variable that can be set to switch between profiles.

## Further reading
- https://aws.amazon.com/cli/
- https://docs.aws.amazon.com/cli/latest/reference/
- https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html
- https://dev.to/andreasbergstrom/juggling-multiple-aws-cli-profiles-like-a-pro-2h88
