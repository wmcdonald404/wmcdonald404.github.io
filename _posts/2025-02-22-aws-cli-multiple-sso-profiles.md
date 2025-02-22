---
title: "Configure the AWS CLI with additional SSO profiles"
tags:
- amazon
- aws
- awscli
- cli
- sso
---

## Overview
Extending AWS CLI SSO and profile configuration with multiple SSO sessions

## Background
In [Configure the AWS CLI with SSO and multiple profiles](https://wmcdonald404.co.uk/2024/02/24/aws-cli-configure-with-sso-profiles.html) you saw how to add multiple profiles to switch easily between accounts/roles.

Your work may have multiple discrete [AWS Organisations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) each with its own [AWS IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html). Or you may use AWS IAM Identity Center in your personal AWS account/organisation. 

This can result in:
- SSO for work org-1
- SSO for work org-2
- SSO for home

You will see how to create additional SSO profiles to accomodate this. Starting from scratch with a clean configuration slate (`mv ~/.aws/ ~/.aws-$($date -I)`)

## How-to
1. Start by creating an initial 'home/personal' SSO session configuration:

    ```shell
    [wmcdonald@fedora ~ ]$ aws configure sso-session 
    SSO session name: homesso
    SSO start URL [None]: https://homesso.awsapps.com/start/
    SSO region [None]: eu-west-1
    SSO registration scopes [sso:account:access]:

    Completed configuring SSO session: homesso
    Run the following to login and refresh access token for this session:

    aws sso login --sso-session homesso
    ```

    Review the `~/.aws/config`:

    ```shell
    [wmcdonald@fedora ~ ]$ cat ~/.aws/config 
    [sso-session homesso]
    sso_start_url = https://homesso.awsapps.com/start/
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access
    ```

2. Next, create an SSO session configuration for work:

    ```shell
    [wmcdonald@fedora ~ ]$ aws configure sso-session 
    SSO session name: worksso
    SSO start URL [None]: https://worksso.awsapps.com/start/
    SSO region [None]: us-east-1
    SSO registration scopes [sso:account:access]:

    Completed configuring SSO session: worksso
    Run the following to login and refresh access token for this session:

    aws sso login --sso-session worksso
    ```

    Review the `~/.aws/config` again:

    ```shell
    [wmcdonald@fedora ~ ]$ cat ~/.aws/config 
    [sso-session homesso]
    sso_start_url = https://d-9367bcd0dd.awsapps.com/start/
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access

    [sso-session worksso]
    sso_start_url = https://worksso.awsapps.com/start/
    sso_region = us-east-1
    sso_registration_scopes = sso:account:access
    ```

3. Now you can create a personal profile associated with the home SSO session you have created:

    ```shell
    [wmcdonald@fedora ~ ]$ aws configure sso --profile homesso.muppetuser
    SSO session name (Recommended): homesso
    Attempting to automatically open the SSO authorization page in your default browser.
    If the browser does not open or you wish to use a different device to authorize this request, open the following URL:

    https://homesso.awsapps.com/start/#/device

    Then enter the code:

    MOOO-DENG
    The only AWS account available to you is: 123412341234
    Using the account ID 123412341234
    The only role available to you is: MuppetAccess
    Using the role name "MuppetAccess"
    CLI default client Region [None]: eu-west-1
    CLI default output format [None]: json

    To use this profile, specify the profile name using --profile, as shown:

    aws s3 ls --profile homesso.muppetuser
    ```

3. Review the `~/.aws/config` state:

    **Note**: these configuration stanzas have been reordered for clarity

    ```ini
    [sso-session homesso]
    sso_start_url = https://homesso.awsapps.com/start/
    sso_region = eu-west-1
    sso_registration_scopes = sso:account:access
    
    [sso-session worksso]
    sso_start_url = https://worksso.awsapps.com/start/
    sso_region = us-east-1
    sso_registration_scopes = sso:account:access
    
    [profile homesso.muppetuser]
    sso_session = homesso
    sso_account_id = 123412341234
    sso_role_name = MuppetAccess
    region = eu-west-1
    output = json
    ```

4. From here, it's simple enough to rinse and repeat for the number of combinations of user/role profile and SSO session:

    ```shell
    [wmcdonald@fedora ~ ]$ aws configure sso --profile worksso.developeraccess
    SSO session name (Recommended): worksso
    <...>
    ```
    
## Summary
That's the basics for multi-profile, multi-sso session handling for the AWS CLI. Wrap a few aliases around some or all combinations for ease of sitching. You can to use simple psuedo namespaced hierarchies if you have lots of combinations to accomodate. The hierarchy may be deeper for work if you have multiple environments, but you can distinguish easily beteween the accounts you're accessing. e.g.

- `workorg`.`product`.`environment`.`role`
- `home`.`role`

You could end up with a hierarchy similar to the following, each leaf mapping to an sso session, account, & role:

```
emea.widgets.nonprod.admin
emea.widgets.nonprod.developer
emea.widgets.prod.admin
emea.widgets.prod.developer
apac.dongles.engineering.dev
apac.dongles.engineering.test
apac.dongles.engineering.release
apac.dongles.manufacturing.dev
apac.dongles.manufacturing.test
apac.dongles.manufacturing.release
apac.dongles.marketing.dev
apac.dongles.marketing.test
apac.dongles.marketing.release
home.dev
home.prod
```

## Further reading
- [https://gbenson.net/sessionless-aws-iam-sso/](https://gbenson.net/sessionless-aws-iam-sso/)
- [https://dev.to/drewmullen/aws-creds-in-the-cli-via-sso-122i](https://dev.to/drewmullen/aws-creds-in-the-cli-via-sso-122i)
- [https://medium.com/@mrethers/boss-way-to-authenticate-aws-cli-with-sso-for-multi-account-orgs-aa8a5e228bdd](https://medium.com/@mrethers/boss-way-to-authenticate-aws-cli-with-sso-for-multi-account-orgs-aa8a5e228bdd)