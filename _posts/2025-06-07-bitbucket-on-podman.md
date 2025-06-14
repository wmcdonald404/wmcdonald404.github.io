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

1. Create a storage volume and start the Bitbucket instance

    ```
    $ podman volume create bitbucket-data
    $ podman run -d --name bitbucket -p 7990:7990 -p 7999:7999 -v bitbucket-data:/var/atlassian/application-data/bitbucket docker.io/atlassian/bitbucket
    ```

2. Check the logs for the startup password

    ```
    $ podman logs bitbucket
    ```

3. Open the Bitbucket web interface [http://localhost:7990/](http://localhost:7990/)

4. Use the Server ID to generate an [Atlassian Trial License](https://www.atlassian.com/purchase/my/license-evaluation)

5. Select "I have a Bitbucket license key" and paste in the generated license.

6. Set up the administrator account, and then select "Go to bitbucket":
  - Username
  - Full name
  - Email address
  - Password
  - Confirm password

# Next Steps

Create some users, groups, projects and repositories. Test API enumeration at http://localhost:7990/rest/api/1.0/projects/

1. Create Projects
2. Make Project default "world" readable

3. Create Users
4. Create Groups
5. Assing
6. Assign Group to Project


# API use TL;DR:

1. Set an environment variable with the admin password.

    ```
    $   BB=<password>
    ```

2. Create a project, check the return value.

    ```
    $ curl \
      -d '{"key":"PDTA","name":"Product Team A","description":"Product Team A. Contact X."}' \
      -H "Content-Type: application/json" \
      -s -u admin:${BB} \
      -X POST http://localhost:7990/rest/api/1.0/projects/

    $ echo $?
    0
    ```

3. Validate existing projects.

    ```
    $ curl -s -u admin:${BB} http://localhost:7990/rest/api/1.0/projects/ | jq
    {
    "size": 1,
    "limit": 25,
    "isLastPage": true,
    "values": [
      {
        "key": "PDTA",
        "id": 25,
        "name": "Product Team A",
        "description": "Product Team A. Contact X.",
        "public": false,
        "type": "NORMAL",
        "links": {
          "self": [
            {
              "href": "http://localhost:7990/projects/PDTA"
            }
          ]
        }
      }
    ],
    "start": 0
    }
    ```

4. Check the project's default permission for 'ALL' (synonymous with default):

    ```
    $ curl -s -u admin:${BB} http://localhost:7990/rest/api/1.0/projects/PDTA/permissions/PROJECT_READ/all
    {"permitted":false}
    ```

5. Switch the [default permission](https://docs.atlassian.com/bitbucket-server/rest/5.16.0/bitbucket-rest.html#idm8286985008) to `PROJECT_READ`

    ```
    $ curl \
        -d '{"permitted":true}' \
        -H "Content-Type: application/json" \
        -s -u admin:${BB} \
        -X POST http://localhost:7990/rest/api/1.0/projects/PDTA/permissions/PROJECT_READ/all?allow=true
    ```


# References
- [Atlassian Trial License](https://www.atlassian.com/purchase/my/license-evaluation)
- [REST Resources Provided By: Bitbucket Server - REST](https://docs.atlassian.com/bitbucket-server/rest/5.16.0/bitbucket-rest.html)
- [/rest/api/1.0/projects/{projectKey}/permissions/{permission}/all](https://docs.atlassian.com/bitbucket-server/rest/5.16.0/bitbucket-rest.html#idm8286985008)