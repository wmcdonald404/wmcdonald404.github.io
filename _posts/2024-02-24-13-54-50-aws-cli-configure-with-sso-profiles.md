---
title: "Configure the AWS CLI with SSO and multiple profiles"
date: 2024-02-24 13-54-50
tags:
- amazon
- aws
- awscli
- cli
- sso
---

## Overview
Extend AWS CLI configuration with multiple profiles (for example work, training or personal accounts) and SSO.

## Background
Building on [Configure the AWS CLI with multiple profiles](https://wmcdonald404.github.io/github-pages/2024/02/21/15-36-48-configure-aws-cli-with-profiles.html), we can extend the AWS CLI configuration to combine multiple profiles with SSO to easily switch between accounts and their resources.

## How-to
1. Install the CLI

    See [Configure the AWS CLI with multiple profiles](https://wmcdonald404.github.io/github-pages/2024/02/21/15-36-48-configure-aws-cli-with-profiles.html)

2. Configure SSO for the AWS CLI

    Start by creating an initial SSO configuration:

    ```
    wmcdonald@fedora:~$ aws configure sso
    SSO session name (Recommended): my-org-sso
    SSO start URL [None]: https://my-org-sso.awsapps.com/start
    SSO region [None]: eu-west-1
    SSO registration scopes [sso:account:access]:
    ```

    At this stage, the AWS CLI will open the default brower, to establish trust:
    
    ```
    Attempting to automatically open the SSO authorization page in your default browser.
    If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

    https://device.sso.<region>.amazonaws.com/
    
    Then enter the code:

    ABCD-LOLO
    ```
    
    Next if multiple accounts are available for the identity, select a sensible base account (we can add additional accounts easily in subsequent steps):
    
    ```
    There are [N] AWS accounts available to you.
    <<select an account>>
    Using the account ID 123412341234
    The only role available to you is: developer
    Using the role name "developer"

    CLI default client Region [None]: eu-west-1
    CLI default output format [None]: json
    ```

3. Review the `~/.aws/config` state:

    **Note**: these configuration stanzas have been reordered for clarity

    ```
    [sso-session my-org-sso]
    sso_start_url = https://my-org-sso.awsapps.com/start
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access

    [profile dev-account.developer]
    sso_session = my-org-sso
    sso_account_id = 123412341234
    sso_role_name = developer
    region = eu-west-1
    output = json
    ```

4. Review the AWS CLI environment variables set:

    ```
    wmcdonald@fedora:~$ set | grep AWS
    AWS_PROFILE=dev-account.developer
    ```
    
    **Note**: if `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` are set this will override `AWS_PROFILE` leading to unexpected results. If set they can be unset:

    ```
    wmcdonald@fedora:~$ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    ```

5. Verify that the account defined in `AWS_PROFILE` can be queried successfully with the SSO session:

    ```
    wmcdonald@fedora:~$ aws ec2 describe-instances | jq '.[][].Instances[].InstanceId'
    "i-034e459b55d574564"
    "i-0af34b3e0f9fecc9e"
    "..."
    ```

6. To extract data from some deeper keys from the JSON returned by `aws ec2 describe-instances`, for example if you have Cloud9 instances and wanted to filter these by instance ID:

    ```
    wmcdonald@fedora:~$ aws ec2 describe-instances | jq -c '.Reservations[].Instances[] | {InstanceID: .InstanceId, InstanceType: .InstanceType, Cloud9Owner: .Tags[] | select(.Key == "aws:cloud9:owner").Value}'
    {"InstanceID":"i-034e459b55d574564","InstanceType":"t3.small","Cloud9Owner":"A0880D35011EEA187F057:bob.typeytype"}
    {"InstanceID":"i-0af34b3e0f9fecc9e","InstanceType":"m5.large","Cloud9Owner":"A0880D35011EEA187F057:alan.syscall"}
    ```

7. To extend the configuration to include additional accounts or roles this can be achieved as shown:

    ```
    [sso-session my-org-sso]
    sso_start_url = https://my-org-sso.awsapps.com/start
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access

    [profile dev-account.developer]
    sso_session = my-org-sso
    sso_account_id = 123412341234
    sso_role_name = developer
    region = eu-west-1
    output = json

    [profile test-account.tester]
    sso_session = my-org-sso
    sso_account_id = 43214321
    sso_role_name = tester
    region = eu-west-2
    output = json
    ```

## Summary
We now have the AWS CLI configured with two profiles, a simple environment variable that can be set to switch between profiles and SSO identity to permit access to cloud resources.

## Further reading
- https://docs.aws.amazon.com/signin/latest/userguide/command-line-sign-in.html
- https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso
- https://ben11kehoe.medium.com/you-only-need-to-call-aws-sso-login-once-for-all-your-profiles-41a334e1b37e
- https://ben11kehoe.medium.com/aws-configuration-files-explained-9a7ea7a5b42e
- https://stackoverflow.com/questions/49987458/aws-profile-not-working-with-aws-cli

- https://aws.amazon.com/cli/
- https://docs.aws.amazon.com/cli/latest/reference/
- https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html


## Topics
{% for tag in page.tags %}
    {{ tag }}
{% endfor %}