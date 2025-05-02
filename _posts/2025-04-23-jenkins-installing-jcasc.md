---
title: "Installing Jenkins Configuration as Code"
tags:
- containers
- jenkins
- podman
- jcasc
---

* TOC
{:toc}

# Overview
Now we can quickly provision a Jenkins instance in a container, next it would be useful to be able to automate all subsequent deployment. Including:
- Management configuration (users, groups, directory integration)
- Plugin deployment
- Plugin configuration

[Jenkins Configuration as Code (aka JCasC)](https://www.jenkins.io/projects/jcasc/) can help with these post-deployment steps. In order to fiddle with JCasC first we need to install the plugin. This should itself be driven from an IaC pipeline but first we need to understand the basic workflow.

# How-to
1. If Jenkins is already up and running, skip to step #2.

    If starting from scratch, `podman run` the Jenkins LTS release

    ```
    $ podman run -d --restart on-failure -p 8080:8080 -u $UID -v jenkins_home:/var/jenkins_home --name jenkins docker.io/jenkins/jenkins:lts
    ```

    If you already have a Jenkins container and volume, but it's shutdown, start it back up:

    ```
    $ podman start jenkins
    ```

2. Install the Jenkins Configuration as Code plugin: 

    ```
    $ podman exec -it jenkins jenkins-plugin-cli --plugins configuration-as-code:1958.vddc0d369b_e16
    Done
    ```

3. Validate the installed plugins: 

    ```shell
    $ podman exec -it jenkins jenkins-plugin-cli --list
    Installed plugins:
    antisamy-markup-formatter 173.v680e3a_b_69ff3
    asm-api 9.8-135.vb_2239d08ee90
    bootstrap5-api 5.3.3-2
    caffeine-api 3.2.0-166.v72a_6d74b_870f
    commons-lang3-api 3.17.0-87.v5cf526e63b_8b_
    commons-text-api 1.13.0-153.v91dcd89e2a_22
    configuration-as-code 1958.vddc0d369b_e16
    font-awesome-api 6.7.2-1
    json-api 20250107-125.v28b_a_ffa_eb_f01
    plugin-util-api 6.1.0
    prism-api 1.30.0-1
    scm-api 704.v3ce5c542825a_
    script-security 1373.vb_b_4a_a_c26fa_00
    snakeyaml-api 2.3-125.v4d77857a_b_402
    structs 343.vdcf37b_a_c81d5
    workflow-api 1371.ve334280b_d611
    workflow-step-api 700.v6e45cb_a_5a_a_21
    workflow-support 968.v8f17397e87b_8
    <...>
    ```

    **Note:** In the UI these plugins will not be shown as installed. A restart is required.

4. Restart Jenkins:

    ```shell
    $ podman stop jenkins && podman start jenkins
    ```

    **Note:** A straight `podman restart jenkins` fails to bind to the port. Possibly a `pasta` issue.


# Notes
## Quick clean up
If you need to start from scratch you can quickly reset by:

```shell
$ podman stop jenkins
$ podman rm jenkins
$ podman volume rm jenkins_home
```

## Safe restart
We can call `safe-restart` using Jenkins CLI option, but we still need to start the container from the container host, even if `--restart always` is set. 

```
$ podman exec -it jenkins sh -c 'java -jar /var/jenkins_home/war/WEB-INF/lib/cli-2.492.3.jar -s http://localhost:8080 -auth admin:`cat /var/jenkins_home/secrets/initialAdminPassword` safe-restart'
```

**Note #2:** From outside the pod, we need to use `sh -c` to permit the backticks/subshell to be passed to the pod unmolested. Inside the pod we can just run `java -jar /var/jenkins_home/war/WEB-INF/lib/cli-2.492.3.jar -s http://localhost:8080 -auth admin:`cat /var/jenkins_home/secrets/initialAdminPassword` safe-restart`

# Next Steps
Now we can do Configuration as Code for Jenkins. 

Tack on an AD instance, set up groups automatically.

# References
- [Configuration as Code](https://plugins.jenkins.io/configuration-as-code/)
- [Introduction to Jenkins Configuration as Code (JCasC) with a Real Example](https://medium.com/@mbanaee61/introduction-to-jenkins-configuration-as-code-jcasc-with-a-real-example-d955fc1a9777)