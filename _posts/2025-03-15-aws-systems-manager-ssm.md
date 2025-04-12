---
title: "AWS Systems Manager SSM"
tags:
- amazon
- aws
- ssm
- systems manager
---

## Overview
AWS Systems Manager is a service that:

> helps you centrally view, manage, and operate nodes at scale in AWS, on-premises, and multicloud environments. With the launch of an unified console experience, Systems Manager consolidates various tools to help you complete common node tasks across AWS accounts and Regions.

SSM Session Manager is commonly used to permit 'gated' console access to EC2 instances in VPC without exposing them to the internet. This is the case we'll configure.

## Prerequisites
1. AWS Systems Manager should be enabled within the [AWS Organisation](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html)
2. Enabling Quick Setup may also be beneficial.
3. An IAM Role with the AmazonSSMManagedInstanceCore Permissions policy applied. The AmazonSSMRoleForInstancesQuickSetup IAM role will suffice if Quick Setup was used.
4. In Systems Manager > Change Management Tools > Quick Setup
   a. Default Host Management Configuration should be configured
   b. Host Management may be required (to be confirmed) 
5. A system with the [AWS CLI installed and configured](https://wmcdonald404.co.uk/2024/02/21/aws-cli-configure-with-profiles.html) and the Session Manager plugin.


## Provisioning
1. Add an `iam_instance_profile` entry to [your instance provisioning](https://github.com/wmcdonald404/terraform-sandbox-aws/blob/cf4abb4dd5b257f53c3beb30efe2001346cb835f/single_az/main.tf#L73)

2. Provision your EC2 instance
    
    ```
    $ terraform plan
    $ terraform apply -auto-approve
    ```

3. List instance(s)

    ```
    $ aws ec2 describe-instances  | jq -rc '.Reservations[].Instances[] | (.InstanceId, .PublicIpAddress)' | paste -d, - - 
    i-06900ca90da3b694f,18.201.137.62
    ```

    > **Note:** This instance currently has a public IP and security groups configured so SSH access can be tested too. SSM does NOT need the instance to be in a public subnet, or have a public IP.

4. Test connectivity

    ```
    wmcdonald@fedora ~ → aws ssm start-session --target i-06900ca90da3b694f

    Starting session with SessionId: wmcdonald808-e2rve9du497c6d6gx8oat9cjia
    $ bash
    ssm-user@ip-10-0-1-86:/var/snap/amazon-ssm-agent/9881$ 
    ```

    > **Note:** The default Debian AMI does not have the [SSM Agent installed out-of-the-box](https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-deb.html). This prevents SSM access unless you inject it via UserData.

    ```
    wmcdonald@fedora single_az ±|main ✗|→ aws ssm start-session --target i-0b4963023b152e1a1

    An error occurred (TargetNotConnected) when calling the StartSession operation: i-0b4963023b152e1a1 is not connected.
    ```

    The Terraform addition to an `aws_instance` definition could include:

    ```
    user_data = <<EOF
    #!/bin/bash
    if [ -f "/etc/debian_version" ]
    then
        mkdir /tmp/ssm
        wget -O /tmp/ssm/amazon-ssm-agent.deb https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb 
        sudo dpkg -i /tmp/ssm/amazon-ssm-agent.deb
    EOF
    ```

5. Configure the local SSH client to wrap connections in SSM. This is the syntax 

    ```
    Host i-0b4963023b152e1a1
        IdentityFile ~/.ssh/keys/wmcdonald@gmail.com-aws-ed25519-key-20211205
        ProxyCommand aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
        User admin
    ```

    **Notes:** 
    - You do not need to specify `IdentityFile` if your `ssh-agent` has the appropriate private key loaded.     
    - You do not need to specify `User` if you are comfortable passing `-l admin` or `admin@<instance-id>` on the connection command line.

6. You can also use SSM to forward ports to access services without exposing them directly to the internet. For example, to forward 8081 on a local system to 8081 on a remote EC2 instance:

    ```
    $ aws ssm start-session --target $INSTANCE_ID \
        --document-name AWS-StartPortForwardingSession \
        --parameters '{"portNumber":["8081"],"localPortNumber":["8081"]}'
    ```

## Further reading
- [https://dev.to/entest/setup-vscode-ssh-remote-to-a-private-ec2-instance-via-ssm-dm7](https://dev.to/entest/setup-vscode-ssh-remote-to-a-private-ec2-instance-via-ssm-dm7)
