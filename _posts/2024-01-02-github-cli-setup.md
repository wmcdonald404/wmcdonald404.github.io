---
title: "Install and configure the GitHub CLI"
tags:
- github
- gh
- cli
---

## Overview
Outline the basic steps to install and configure the Github CLI on Fedora (currently 39).

## Background
To quote chaper-and-verse from the package description:

> A command-line interface to GitHub for use in your terminal or your scripts.
>
> gh is a tool designed to enhance your workflow when working with GitHub. It provides a seamless way to interact with GitHub repositories and perform various actions right from the command line, eliminating the need to switch between your terminal and the GitHub website.

Having the CLI to-hand can streamline an engineer's workflow, reducing context switching from the development environment to the Github web UI.

## How-to
1. Install the CLI

    There are a [number of installation options available](https://github.com/cli/cli#installation), however when using a distribution with a mature but up-to-date package ecosystem, it can be as simple as installing from the package manager.

    ```
    wmcdonald@fedora:~$ sudo dnf info gh
    Last metadata expiration check: 0:00:46 ago on Tue 02 Jan 2024 21:03:23 GMT.
    Installed Packages
    Name         : gh
    Version      : 2.40.1
    Release      : 1.fc39
    Architecture : x86_64
    Size         : 46 M
    Source       : gh-2.40.1-1.fc39.src.rpm
    Repository   : @System
    From repo    : updates
    Summary      : GitHub's official command line tool
    URL          : https://github.com/cli/cli
    License      : MIT
    Description  : A command-line interface to GitHub for use in your terminal or your scripts.
                : 
                : gh is a tool designed to enhance your workflow when working with GitHub. It
                : provides a seamless way to interact with GitHub repositories and perform various
                : actions right from the command line, eliminating the need to switch between your
                : terminal and the GitHub website.

    wmcdonald@fedora:~$ sudo dnf -y install gh
    ```

2. Validate that the Github CLI runs

    ```
    wmcdonald@fedora:~$ gh --help | head
    Work seamlessly with GitHub from the command line.

    USAGE
      gh <command> <subcommand> [flags]

    CORE COMMANDS
      auth:        Authenticate gh and git with GitHub
      browse:      Open the repository in the browser
      codespace:   Connect to and manage codespaces
      gist:        Manage gists
    ```

3. Authenticate to Github using the CLI

    Start the Github CLI authentication process:
    ```
    wmcdonald@fedora:~$ gh auth login -h github.com -p https
    ```
    Select 'Authenticate with credentials': **(Y)**:
    ```
    ? Authenticate Git with your GitHub credentials? (Y/n) 
    ```
    Select 'Login with browser':
    ```
    ? How would you like to authenticate GitHub CLI? Login with a web browser
    ```
    Select one-time code and copy the resulting code:
    ```
    ! First copy your one-time code: WXYZ-ABCD
    ```
    Open a browser when prompted:
    ```
    Press Enter to open github.com in your browser... 
    ```
    Enter the one-time code in the launched browser session:
    ```
    WXYZ-ABCD
    ```
    Authorize Github in the launched browser session:
    ```
    Authorize Github
    ```
    Confirm with a OTP authentication code from a trusted device providing OTP tokens.

    Confirm the sign in was successful:
    ```
    ✓ Authentication complete.
    - gh config set -h github.com git_protocol https
    ✓ Configured git protocol
    ✓ Logged in as wmcdonald404
    ```

4. Set a [`GH_REPO`](https://cli.github.com/manual/gh_help_environment) environment variable

    ```
    wmcdonald@fedora:~$ export GH_REPO='https://github.com/wmcdonald404/github-pages' 
    ```

## Summary
With the Github CLI installed, and the [`GH_REPO`](https://cli.github.com/manual/gh_help_environment) set appropriately, the CLI can be used to query the state of the repo, review PRs, trigger Github actions workflows, review runs and many other activities.

For example:

```
wmcdonald@fedora:~$ gh workflow list
NAME                    STATE   ID      
pages-build-deployment  active  80950398
wmcdonald@fedora:~$ gh run list
STATUS  TITLE                       WORKFLOW                BRANCH  EVENT    ID          ELAPSED  AGE              
✓       pages build and deployment  pages-build-deployment  main    dynamic  7432457879  43s      about 3 hours ago
✓       pages build and deployment  pages-build-deployment  main    dynamic  7432432790  46s      about 3 hours ago
✓       pages build and deployment  pages-build-deployment  main    dynamic  7390698149  45s      about 3 days ago

```
## Further reading
- https://github.com/cli/cli
- https://cli.github.com/manual/
