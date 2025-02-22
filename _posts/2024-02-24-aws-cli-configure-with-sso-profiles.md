---
title: "Configure the AWS CLI with SSO and multiple user profiles"
tags:
- amazon
- aws
- awscli
- cli
- sso
---

## Overview
Extend AWS CLI configuration with multiple user profiles and an SSO session.

## Background
You may have separate SSO accounts and roles granted  per-application (e.g. service-a or service-b) or per-environment (e.g.  nonprod or prod). You will see how to configure each scenario and conveniently switch between profiles. 


Building on [Configure the AWS CLI with multiple profiles](https://wmcdonald404.co.uk/2024/02/21/aws-cli-configure-with-profiles.html), you can extend the AWS CLI configuration to combine multiple user/account profiles with one defined SSO session to easily switch between accounts and their resources.


## How-to
1. Install the CLI

    See [Configure the AWS CLI with multiple profiles](https://wmcdonald404.co.uk/2024/02/21/aws-cli-configure-with-profiles.html)

2. Configure SSO for the AWS CLI

    Start by creating an initial SSO configuration:

    ```shell
    wmcdonald@fedora:~$ aws configure sso
    SSO session name (Recommended): worksso
    SSO start URL [None]: https://worksso.awsapps.com/start
    SSO region [None]: eu-west-1
    SSO registration scopes [sso:account:access]:
    ```

    At this stage, the AWS CLI will open the default brower, to establish trust:
    
    ```shell
    Attempting to automatically open the SSO authorization page in your default browser.
    If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

    https://device.sso.<region>.amazonaws.com/
    
    Then enter the code:

    ABCD-LOLO
    ```
    
    Next if multiple accounts are available for the identity, select a sensible base account (we can add additional accounts easily in subsequent steps):
    
    ```shell
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

    ```ini
    [sso-session worksso]
    sso_start_url = https://worksso.awsapps.com/start
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access

    [profile worksso.developer]
    sso_session = worksso
    sso_account_id = 123412341234
    sso_role_name = developer
    region = eu-west-1
    output = json
    ```

4. Review the AWS CLI environment variables set:

    ```shell
    wmcdonald@fedora:~$ set | grep AWS
    AWS_PROFILE=worksso.developer
    ```
    
    **Note**: if `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` are set this will override `AWS_PROFILE` leading to unexpected results. If set they can be unset:

    ```shell
    wmcdonald@fedora:~$ unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    ```

5. Verify that the account defined in `AWS_PROFILE` can be queried successfully with the SSO session:

    ```shell
    wmcdonald@fedora:~$ aws ec2 describe-instances | jq '.[][].Instances[].InstanceId'
    "i-034e459b55d574564"
    "i-0af34b3e0f9fecc9e"
    "..."
    ```

6. To extract data from some deeper keys from the JSON returned by `aws ec2 describe-instances`, for example if you have Cloud9 instances and wanted to filter these by instance ID:

    ```shell
    wmcdonald@fedora:~$ aws ec2 describe-instances | jq -c '.Reservations[].Instances[] | {InstanceID: .InstanceId, InstanceType: .InstanceType, Cloud9Owner: .Tags[] | select(.Key == "aws:cloud9:owner").Value}'
    {"InstanceID":"i-034e459b55d574564","InstanceType":"t3.small","Cloud9Owner":"A0880D35011EEA187F057:bob.typeytype"}
    {"InstanceID":"i-0af34b3e0f9fecc9e","InstanceType":"m5.large","Cloud9Owner":"A0880D35011EEA187F057:alan.syscall"}
    ```

7. To extend the configuration to include additional accounts or roles this can be achieved as shown:

    ```ini
    [sso-session worksso]
    sso_start_url = https://worksso.awsapps.com/start
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access

    [profile worksso.developer]
    sso_session = worksso
    sso_account_id = 123412341234
    sso_role_name = developer
    region = eu-west-1
    output = json

    [profile worksso.tester]
    sso_session = worksso
    sso_account_id = 43214321
    sso_role_name = tester
    region = eu-west-2
    output = json
    ```

8. You can list configured profiles using `aws configure list-profiles`:

    ```shell
    [wmcdonald@fedora ~ ]$ aws configure list-profiles 
    worksso.developer
    worksso.tester
    ```

9. Pulling this together, some aliases can be set up to toggle between each profile:

    ```shell
    [wmcdonald@fedora ~ ]$ alias | grep -i aws 
    alias worksso.developer='AWS_PROFILE=worksso.developer'
    alias worksso.tester='AWS_PROFILE=worksso.tester'
    ```

## Summary
We now have the AWS CLI configured with two profiles, a simple environment variable that can be set to switch between profiles and SSO identity to permit access to cloud resources.

## Further reading
- [https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [https://docs.aws.amazon.com/signin/latest/userguide/command-line-sign-in.html](https://docs.aws.amazon.com/signin/latest/userguide/command-line-sign-in.html)
- [https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso](https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html#sso-configure-profile-token-auto-sso)
- [https://ben11kehoe.medium.com/you-only-need-to-call-aws-sso-login-once-for-all-your-profiles-41a334e1b37e](https://ben11kehoe.medium.com/you-only-need-to-call-aws-sso-login-once-for-all-your-profiles-41a334e1b37e)
- [https://ben11kehoe.medium.com/aws-configuration-files-explained-9a7ea7a5b42e](https://ben11kehoe.medium.com/aws-configuration-files-explained-9a7ea7a5b42e)
- [https://stackoverflow.com/questions/49987458/aws-profile-not-working-with-aws-cli](https://stackoverflow.com/questions/49987458/aws-profile-not-working-with-aws-cli)
- [https://aws.amazon.com/cli/](https://aws.amazon.com/cli/)
- [https://docs.aws.amazon.com/cli/latest/reference/](https://docs.aws.amazon.com/cli/latest/reference/)
- [https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/index.html)
