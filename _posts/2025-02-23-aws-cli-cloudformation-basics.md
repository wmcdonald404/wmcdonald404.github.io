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

## How-to - Basic Provisioning

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

    And just verify that the file has uploaded

    ```shell
    [wmcdonald@fedora cftest ]$ aws s3 ls simple-template.json s3://cf-templates-123412341234
    2025-02-22 20:44:27       2992 simple-template.json
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

8. Verify that an EC2 instance has been created

    ```shell
    [wmcdonald@fedora cftest ]$ aws ec2 describe-instances
    {
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-08a28be5eae6c1d68",
                    "InstanceId": "i-071897e5de041801e",
                    "InstanceType": "t2.micro",
                    "LaunchTime": "2025-02-23T11:34:48+00:00",
    <output snipped>

    [wmcdonald@fedora cftest ]$ aws ec2 describe-instances | jq '.Reservations[].Instances[] | "\(.InstanceId),\(.InstanceType),\(.PublicDnsName),\(.Tags[] | select(.Key == "aws:cloudformation:stack-name").Value),\(.Tags[] | select(.Key == "aws:cloudformation:logical-id").Value)"'
    "i-071897e5de041801e,t2.micro,ec2-34-248-121-119.eu-west-1.compute.amazonaws.com,urltest,WebServer"
    ```

9. Validate that the URL in the OutputValue can be accessed:

    ```shell
    [wmcdonald@fedora cftest ]$ curl http://ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    <html><body><h1>Hello World!</h1></body></html>
    ```

10. KILL IT WITH FIRE. (Delete the stack)

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation delete-stack --stack-name urltest

11. Check that the Cloudformation Stack has gone

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation list-stacks | jq -c '.StackSummaries.[] | { Name: .StackName, Status: .StackStatus }'
    {"Name":"urltest","Status":"DELETE_COMPLETE"}
    ```

12. Check you can no longer `curl` the URL

    ```shell
    [wmcdonald@fedora cftest ]$ curl --connect-timeout 30 http://ec2-34-248-121-119.eu-west-1.compute.amazonaws.com
    curl: (28) Failed to connect to ec2-34-248-121-119.eu-west-1.compute.amazonaws.com port 80 after 30002 ms: Timeout was reached
    ```

13. Check the state of the EC2 instance, while the instance state is still returned from AWS, note that it is in `terminated` state

    ```shell
    [wmcdonald@fedora cftest ]$ aws ec2 describe-instances
    [wmcdonald@fedora cftest ]$ aws ec2 describe-instances | jq '.Reservations[].Instances[] | (.InstanceId, .State)'
    "i-071897e5de041801e"
    {
    "Code": 48,
    "Name": "terminated"
    }
    ```

14. It's likely the host will still resolve from a local, caching resolver, but you can check an AWS nameserver directly which should return no results relatively quickly:

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

## How-to - Passing Parameters

Now you can create, review and destroy basic infrastructure using Cloudformation, the next task is to understand the basics of Cloudformation's parameters.

1. Review the `InstanceType` constraint defined in your `simple-template.json`

    ```shell
    [wmcdonald@fedora cftest ]$ jq '.Parameters.InstanceType' simple-template.json 
    {
        "Description": "WebServer EC2 instance type",
        "Type": "String",
        "Default": "t2.micro",
        "AllowedValues": [
            "t3.micro",
            "t2.micro"
        ],
        "ConstraintDescription": "must be a valid EC2 instance type."
    }
    ```

2. Edit and update this to include a larger instance type, `t2.medium`

    ```shell
    [wmcdonald@fedora cftest ]$ jq '.Parameters.InstanceType' simple-template.json 
    {
        "Description": "WebServer EC2 instance type",
        "Type": "String",
        "Default": "t2.micro",
        "AllowedValues": [
            "t2.medium",
            "t3.micro",
            "t2.micro"
        ],
        "ConstraintDescription": "must be a valid EC2 instance type."
    }
    ```

3. At this stage, you can either create a new stack directly from the updated local file, or update the S3 bucket copy. Let's update the S3 bucket

    ```shell
    # list buckets
    [wmcdonald@fedora cftest ]$ aws s3 ls 
    2025-02-22 20:01:58 cf-templates-123412341234

    # list contents of your CF template bucket
    [wmcdonald@fedora cftest ]$ aws s3 ls cf-templates-123412341234
    2025-02-22 20:44:27       2992 simple-template.json

    # copy the updated template into the bucket
    [wmcdonald@fedora cftest ]$ aws s3 cp simple-template.json s3://cf-templates-123412341234
    upload: ./simple-template.json to s3://cf-templates-123412341234/simple-template.json

    # validate bucket contents, note timestamp and file size change
    [wmcdonald@fedora cftest ]$ aws s3 ls cf-templates-123412341234
    2025-02-23 13:15:17       3022 simple-template.json
    
    # double-check the AllowedValues
    [wmcdonald@fedora cftest ]$ aws s3 cp s3://cf-templates-123412341234/simple-template.json - | jq '.Parameters.InstanceType'
    {
        "Description": "WebServer EC2 instance type",
        "Type": "String",
        "Default": "t2.micro",
        "AllowedValues": [
            "t2.medium",
            "t3.micro",
            "t2.micro"
        ],
        "ConstraintDescription": "must be a valid EC2 instance type."
    }
    ```

4. Create the stack from the template, using a `template-url` pointing to the S3 bucket's HTTPS URL. This time include the additional parameter specification to deploy a `t2.medium` sized instance, overriding the template's default 

    ```shell
    [wmcdonald@fedora cftest ]$ aws ec2 describe-instances
    {
        "Reservations": []
    }
 
    [wmcdonald@fedora cftest ]$ CFTEMPLATE=https://cf-templates-123412341234.s3.eu-west-1.amazonaws.com/simple-template.json
    [wmcdonald@fedora cftest ]$ aws cloudformation create-stack --stack-name urltest --template-url ${CFTEMPLATE} --parameters ParameterKey=InstanceType,ParameterValue=t2.medium
    ```

5. Again, we can review the state of the Cloudformation provisioning run, the outputs of the Cloudformation stack, verify that an EC2 instance has been created and verify it's using the new instance type.

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation list-stacks | jq -c '.StackSummaries.[] | { Name: .StackName, Status: .StackStatus }'
    {"Name":"urltest","Status":"CREATE_COMPLETE"}

    [wmcdonald@fedora cftest ]$ aws cloudformation describe-stacks --stack-name urltest | jq -c '.Stacks.[] | .StackName, .Outputs'
    "urltest"
    [{"OutputKey":"WebsiteURL","OutputValue":"http://ec2-54-170-144-93.eu-west-1.compute.amazonaws.com","Description":"Website URL"}]

    [wmcdonald@fedora cftest ]$ aws ec2 describe-instances | jq '.Reservations[].Instances[] | "\(.InstanceId),\(.InstanceType),\(.PublicDnsName),\(.Tags[] | select(.Key == "aws:cloudformation:stack-name").Value)"'
    "i-0fdd96b02ac55456f,t2.medium,ec2-54-170-144-93.eu-west-1.compute.amazonaws.com,urltest"

    [wmcdonald@fedora cftest ]$ curl ec2-54-170-144-93.eu-west-1.compute.amazonaws.com
    <html><body><h1>Hello World!</h1></body></html>
    ```

6. And again, KILL IT WITH FIRE. (Delete the stack)

    ```shell
    [wmcdonald@fedora cftest ]$ aws cloudformation delete-stack --stack-name urltest
    
    [wmcdonald@fedora cftest ]$ aws cloudformation list-stacks | jq -c '.StackSummaries.[] | { Name: .StackName, Status: .StackStatus }'
    {"Name":"urltest","Status":"DELETE_IN_PROGRESS"}
    
    [wmcdonald@fedora cftest ]$ aws cloudformation list-stacks | jq -c '.StackSummaries.[] | { Name: .StackName, Status: .StackStatus }'
    {"Name":"urltest","Status":"DELETE_COMPLETE"}
    ```

## Summary
That's the basics of Cloudformation. We can create basic infrastructure using templates, and inject parameters to override defaults.


## Further reading
- [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/GettingStarted.html)
