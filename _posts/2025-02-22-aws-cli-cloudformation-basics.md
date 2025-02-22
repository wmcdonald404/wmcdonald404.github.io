---
title: "Basic AWS Cloudformation EC2 Instance Provisioning"
tags:
- amazon
- aws
- awscli
- cli
- cloudformation
---

## Overview
A simple run through of the steps to create, verify and then destroy an AWS EC2 instance using Cloudformation.

## Background
Cloudformation templates can be used to provide paramaterised pre-baked infrastructure configuration. Often used where a central cloud team (a CCoE or cloud platform team, for example) provide tested and integrated infrastructure components for consumption by downstream line-of-business teams to self-service within defined guard rails.

## How-to

1. Log in to your AWS organisation

2. Create a Cloudformation template

    The Cloudformation template from [Creating your first stack - Create a CloudFormation stack with the console](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/gettingstarted.walkthrough.html#getting-started-create-stack) is replicated in [this Github Gist](https://gist.github.com/wmcdonald404/bddfa345a4adf872bea0f150394403f7). 

    [YAML](https://gist.githubusercontent.com/wmcdonald404/bddfa345a4adf872bea0f150394403f7/raw/dceaeac9c976c5081358aeb25b49ce94031548db/simple-template.yaml) is considered easier to read/understand by many, while [JSON](https://gist.githubusercontent.com/wmcdonald404/bddfa345a4adf872bea0f150394403f7/raw/dceaeac9c976c5081358aeb25b49ce94031548db/simple-template.json) is [less error-prone](https://ruudvanasseldonk.com/2023/01/11/the-yaml-document-from-hell) and easier to machine-parse.

    ```shell
    [wmcdonald@fedora ~ ]$ mkdir cftest && cd cftest
    [wmcdonald@fedora cftest ]$ curl -so simple-template.json  https://gist.githubusercontent.com/wmcdonald404/bddfa345a4adf872bea0f150394403f7/raw/dceaeac9c976c5081358aeb25b49ce94031548db/simple-template.json
    ```

    > Note:The next steps use an S3 bucket to stage the Cloudformation template. You can also use a local template body directly, this will also be demonstrated.

3. Create an S3 bucket

    ```shell
    [wmcdonald@fedora ~ ]$ aws s3 mb s3://cf-templates-123412341234 --region eu-west-1
    make_bucket: cf-templates-123412341234
    ```

4. Upload this to your S3 bucket

    ```shell
    [wmcdonald@fedora cftest ]$ aws s3 cp simple-template.json s3://cf-templates-123412341234
    upload: ./simple-template.json to s3://cf-templates-123412341234/simple-template.json
    ```

5. Create the stack from the template, using a `template-url` pointing to the S3 bucket's HTTPS URL, or we can use the `template-body` from a local file 

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation create-stack --stack-name filetest --template-body file://simple-template.json
    {
        "StackId": "arn:aws:cloudformation:eu-west-1:123412341234:stack/teststack-localfile/04a80030-f163-11ef-b226-02187a1314d9"
    }
    ```

    Or:

    ```shell
    [wmcdonald@fedora cftest ]$ CFTEMPLATE=https://cf-templates-123412341234.s3.eu-west-1.amazonaws.com/simple-template.json
    [wmcdonald@fedora cftest ]$ aws cloudformation create-stack --stack-name urltest --template-url ${CFTEMPLATE}
    ```

6. Check the state of the Cloudformation provisioning run

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation list-stacks | jq -c '.StackSummaries.[] | { Name: .StackName, Status: .StackStatus }'
    {"Name":"urltest","Status":"CREATE_COMPLETE"}
    ```

7. Review the outputs of the Cloudformation stack

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation describe-stacks --stack-name urltest | jq '.Stacks.[] | .StackName, .Outputs'
    "urltest"
    [
        {
            "OutputKey": "WebsiteURL",
            "OutputValue": "http://ec2-34-248-121-119.eu-west-1.compute.amazonaws.com",
            "Description": "Website URL"
        }
    ]
    ```

8. Validate that the URL in the OutputValue can be accessed:

    ```shell
    [wmcdonald@fedora cftest ]$ curl http://ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    <html><body><h1>Hello World!</h1></body></html>
    ```
9. KILL IT WITH FIRE. (Delete the stack)

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation delete-stack --stack-name urltest

10. Check that the Cloudformation Stack has gone

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation list-stacks | jq -c '.StackSummaries.[] | { Name: .StackName, Status: .StackStatus }'
    {"Name":"urltest","Status":"DELETE_COMPLETE"}
    ```

11. Check you can no longer `curl` the URL

    ```shell
    [wmcdonald@fedora cftest ]$ curl --connect-timeout 30 http://ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    curl: (28) Failed to connect to ec2-34-248-121-119.eu-west-1.compute.amazonaws.com port 80 after 30002 ms: Timeout was reached
    ```

12. It's likely the host will still resolve from a local, caching resolver, but you can check an AWS nameserver directly which should return no results relatively quickly:

    ```shell
    [wmcdonald@fedora cftest ]$ host ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    ec2-34-248-121-119.eu-west-1.compute.amazonaws.com has address 34.248.121.119
    
    [wmcdonald@fedora cftest ]$ host ec2-34-248-121-119.eu-west-1.compute.amazonaws.com ns-1670.awsdns-16.co.uk.
    Using domain server:
    Name: ns-1670.awsdns-16.co.uk.
    Address: 205.251.198.134#53
    Aliases: 
    ```

    Or compare:
    
    ```shell
    [wmcdonald@fedora cftest ]$ dig +noall +answer a ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    ec2-34-248-121-119.eu-west-1.compute.amazonaws.com. 5472 IN A 34.248.121.119

    [wmcdonald@fedora cftest ]$ dig +noall +answer @ns-1670.awsdns-16.co.uk. a ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    ```

## Summary
That's the basics of Cloudformation. You can also inject parameters into the template at invocation, for example to create different EC2 instance types.


## Further reading
- [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.html)
