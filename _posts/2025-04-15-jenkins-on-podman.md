---
title: "Running Jenkins CI with Podman"
tags:
- containers
- jenkins
- podman
---

* TOC
{:toc}

# Overview
This is just a quick-and-dirty how-to to spin up a small Jenkins instance to test features, mess with the API and understand the configuration elements in order to deploy a more enterprise-ready version down the line.

# How-to

1. Start the Jenkins LTS release

    ```
    $ podman volume create jenkins-data
    $ podman run -d -p 8082:8080 -u $UID -v jenkins-data:/var/jenkins_home --name jenkins docker.io/jenkins/jenkins:lts
    ```

2. Check the logs for the startup password

    ```
    $ Jenkins initial setup is required. An admin user has been created and a password generated.
    Please use the following password to proceed to installation:

    a97fb91133b3013fefb5fd9sdf8sdf987

    This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
    ```

    Or `cat` the `initialAdminPassword`

    ```
    $ podman exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
    a97fb91133b3013fefb5fd9sdf8sdf987

    ```

3. You should now be able to log in to the Jenkins instance at [http://localhost:8082](http://localhost:8082)


# Next Steps
This is VERY quick and dirty, you should automate the post-startup config. Add TLS, impose sensible OOTB configuration defaults and all the other day-to-day operational tasks required by any piece of infrastructure.

# API use TL;DR:

```
$ JT=$(podman exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword | dos2unix)

$ curl -s -u admin:${JT} http://localhost:8082/api/json | jq keys
[
  "_class",
  "assignedLabels",
  "description",
  "jobs",
  "mode",
  "nodeDescription",
  "nodeName",
  "numExecutors",
  "overallLoad",
  "primaryView",
  "quietDownReason",
  "quietingDown",
  "slaveAgentPort",
  "unlabeledLoad",
  "url",
  "useCrumbs",
  "useSecurity",
  "views"
]
```

# References
- [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
- [Introduction to Jenkins Configuration as Code (JCasC) with a Real Example](https://medium.com/@mbanaee61/introduction-to-jenkins-configuration-as-code-jcasc-with-a-real-example-d955fc1a9777)
- [https://8gwifi.org/docs/podman-jenkins.jsp](https://8gwifi.org/docs/podman-jenkins.jsp)