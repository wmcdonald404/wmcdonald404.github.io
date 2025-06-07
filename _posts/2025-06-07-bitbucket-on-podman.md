---
title: "Running Bitbucket with Podman"
tags:
- containers
- bitbucket
- podman
---

* TOC
{:toc}

# Overview
This is just a quick-and-dirty how-to to spin up a small Bitbucket instance to test features, mess with the API and understand the configuration elements in order to deploy a more enterprise-ready version down the line.

# How-to

1. Start the Jenkins LTS release

    ```
    $ podman volume create jenkins-data
    $ podman run -d -p 8082:8080 -u $UID -v jenkins-data:/var/jenkins_home --name jenkins docker.io/jenkins/jenkins:lts
    ```

2. Check the logs for the startup password

    ```
    $ podman logs bitbucket
    ```

3. Open the Bitbucket web interface [http://localhost:7990/](http://localhost:7990/)

4. Use the Server ID to generate an [Atlassian Trial License](https://www.atlassian.com/purchase/my/license-evaluation)

5. Select "I have a Bitbucket license key" and paste in the generated license.

6. Set up the administrator account, and then select "Go to bitbucket:
  - Username
  - Full name
  - Email address
  - Password
  - Confirm password

# Next Steps

Create some users, groups, projects and repositories. Test API enumeration at http://localhost:7990/rest/api/1.0/projects/

# API use TL;DR:

```
$   BB=<password>

$ $ curl -s -u admin:${BB} http://localhost:7990/rest/api/1.0/projects/ | jq
{
  "size": 2,
  "limit": 25,
  "isLastPage": true,
  "values": [
    {
      "key": "PRJ1",
      "id": 1,
      "name": "Project 1",
      "public": false,
      "type": "NORMAL",
      "links": {
        "self": [
          {
            "href": "http://localhost:7990/projects/PRJ1"
          }
        ]
      }
    },
    {
      "key": "PRJ2",
      "id": 2,
      "name": "Project 2",
      "public": false,
      "type": "NORMAL",
      "links": {
        "self": [
          {
            "href": "http://localhost:7990/projects/PRJ2"
          }
        ]
      }
    }
  ],
  "start": 0
}
```

# References
- [Atlassian Trial License](https://www.atlassian.com/purchase/my/license-evaluation)
