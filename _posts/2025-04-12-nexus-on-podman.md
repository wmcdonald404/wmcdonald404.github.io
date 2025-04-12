---
title: "Running Sonatype Nexus Repository with Podman"
tags:
- containers
- nexus
- podman
---

* TOC
{:toc}

# Overview
This is just a quick-and-dirty how-to to spin up a small Nexus instance to test features, mess with the API and understand the configuration elements in order to deploy a more enterprise-ready version down the line.

# How-to

1. Start the container:
    ```
    $ podman run -d -p 8081:8081 --name nexus docker.io/sonatype/nexus3:latest
    ```

2. Check the logs to ensure the container has started:

    ```
    $ podman logs nexus | grep 'Started Sonatype'
    2025-04-12 16:50:51,409+0000 INFO  [main] *SYSTEM org.sonatype.nexus.bootstrap.application.SonatypeNexusRepositoryApplication - Started SonatypeNexusRepositoryApplication in 2.116 seconds (process running for 2.802)
    Started Sonatype Nexus COMMUNITY 3.79.1-04
    ```

3. `cat` the admin password file and note the auto-generated admin password:

    ```
    $ NEXUS_PASS=$(podman exec nexus cat /nexus-data/admin.password)
    $ echo $NEXUS_PASS
    ```

4. We can now log-in via http://localhost:8081/.
    - username: `admin`
    - password: the contents of `$NEXUS_PASS`

5. We can ennumerate the API path endpoints:

    ```
    $ curl -s http://localhost:8081/service/rest/swagger.json | jq '.paths | keys'
    [
      "/beta/system/information",
      "/v1/assets",
      "/v1/assets/{id}",
      "/v1/azureblobstore/test-connection",
      "/v1/blobstores",
      ...
    ```

6. And verify that we can interact with the API endpoints: 

    ```
    $ curl -u admin:${NEXUS_PASS} "http://localhost:8081/service/rest/v1/status/check"
    ```


# References
- [Download Sonatype Nexus Repository](https://help.sonatype.com/en/download.html)
- [Sonatype Nexus Repository REST API](https://help.sonatype.com/en/automation.html#rest-api)
- [nexus3-cli](https://nexus3-cli.readthedocs.io/en/latest/cli.html#nexus3)
- [Easiest Way To Run Nexus With Docker](https://www.devopsexplained.com/post/easiest-way-to-run-nexus-with-docker/)
- [Sonatype Nexus Repository](https://hub.docker.com/r/sonatype/nexus3/)
- [Sonatype Nexus Repository + Nginx Reverse Proxy Deployment](https://medium.com/@johanesmistrialdo/sonatype-nexus-repository-nginx-reverse-proxy-deployment-947923c6f160)
