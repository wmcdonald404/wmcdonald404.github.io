---
title: Gitlab CLI Installation, Setup and Use
date: 2024-04-19 18:27:07
tags:
- gitlab 
---

## Overview
The Gitlab CLI is, again, to [quote the upstream documentation](https://gitlab.com/gitlab-org/cli):
> an open source GitLab CLI tool bringing GitLab to your terminal next to where you are already working with git and your code without switching between windows and browser tabs. Work with issues, merge requests, watch running pipelines directly from your CLI among other features.
> `glab` is available for repositories hosted on GitLab.com and self-managed GitLab instances. `glab` supports multiple authenticated GitLab instances and automatically detects the authenticated hostname from the remotes available in the working Git directory.


## Background
I've been working with Gitlab groups, repos and pipelines recently. Some of the concepts and primitives used with Gitlab differ from Github or Azure Devops.

The `glab` CLI has proved invaluable mapping groups, repos, exporting repo, viewing and interacting with pipeline runs.

## How-to
1. Installing the Gitlab CLI

    Fedora: `sudo dnf -y install glab`

    Amazon Linux 2023: `sudo dnf -y install https://gitlab.com/gitlab-org/cli/-/releases/v1.38.0/downloads/glab_1.38.0_Linux_x86_64.rpm`

    Windows: `PS C:\Users\vagrant> Invoke-WebRequest https://gitlab.com/gitlab-org/cli/-/releases/v1.39.0/downloads/glab.exe -OutFile C:\Windows\System32\glab.exe`
    

2. Login to Gitlab:

    ```
    $ glab auth login --hostname gitlab.com
    $ glab auth status
    ```

3. Stop the CLI notifying about newer releases (optional):

    ```
    $ glab config set check_update false --global
    ```

4. Now we can list groups, repositories, pipelines, call the API directly etc.

    ```
    $ glab repo list
    $ cd ~/repos/org/group/repo
    $ glab ci list
    $ glab api groups?include_subgroups=true
    ```

5. Watch a pipeline during execution
    ```
    $ cd ~/repos/org/group/repo
    $ git add .
    $ git commit -m 'Bish bash bosh'
    $ git push
    $ glab ci view
    ```
    
## Summary
That's the starter for 10. We've installed the CLI, authenticated against Gitlab and explored some of the basics.


## Further reading
- [Gitlab CLI](https://gitlab.com/gitlab-org/cli#installation)
