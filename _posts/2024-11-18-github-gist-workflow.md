---
title: "Github Gist Workflow with the GitHub CLI"
tags:
- github
- gh
- cli
- gist
---

# Overview
We covered the process of installing and configuring the [Github CLI quite a few months ago](https://wmcdonald404.co.uk/2024/01/02/github-cli-setup.html).

Next we look at managing Gists from the command line (or the terminal in our editor) for convenience. 

# Background
Github's [Gists](https://docs.github.com/en/get-started/writing-on-github/editing-and-sharing-content-with-gists/creating-gists#about-gists), to yet again steal boilerplate directly from the Octocat's mouth:

>  provide a simple way to share code snippets with others. Every gist is a Git repository, which means that it can be forked and cloned. If you are signed in to GitHub when you create a gist, the gist will be associated with your account and you will see it in your list of gists when you navigate to your gist home page. 

As before, having the CLI to-hand can streamline your workflow, reducing context switching from the development environment to the Github web UI. 

Most people will start with Gists in the UI, but having a handy CLI mechanism to create/update means you can work directly from your terminal. 

# How-to
## Working with Existing Gists

1. List your existing Gists using the `gh` CLI:

    ```shell
    [wmcdonald@fedora ~ ]$ cd ~/repos/wmcdonald404/gists/
    [wmcdonald@fedora gists ]$ gh gist list --public
    ID                                DESCRIPTION                                                                  FILES   VISIBILITY  UPDATED            
    d4fb1f0dffeb17c4831f669b767f43b4  Powershell - Powershell MSI Center User Scenario                             1 file  public      about 8 minutes ago
    23c84e2d674be0735f927c20c4c2fcb3  TODO                                                                         1 file  public      about 7 days ago
    7ec99bc35c50ad29e26e4290abfddfba  Vagrant - Vagrant Hints and Tips                                             1 file  public      about 7 minutes ago
    b6dafc402ade36c4383ecf434694e5ca  Bash - Oh My Bash custom aliases                                             1 file  public      about 6 minutes ago
    7c91126481a32bb64e5d3d62c04f2075  Fedora - Fedora Container with Systemd                                       1 file  public      about 9 minutes ago
    45be8efc92730335158daf7e8ec1db86  Vagrant - Gallery3 in a Vagrant Box                                          1 file  public      about 4 minutes ago
    d9df4492d4a102e4a8f49c9aaa05e93e  Python - Python Packaging Managers/Tools                                     1 file  public      about 5 minutes ago
    77025d56a21f8a747fc849c33478a1e9  Powershell - Finding, Listing and Removing Windows Packages with Powershell  1 file  public      about 2 minutes ago
    0501ca45f514dcac9e47dc87fbb1a3fa  Containers - Display forwarding in a devcontainer                            1 file  public      about 2 minutes ago
    146b2f19bf4d28252e12c6da168bf956  Fedora - Installing man pages in a Fedora container                          1 file  public      about 9 minutes ago
    ```

    > **Note:** `gh gist list` limits/paginates its output to 10 entries. Use `gh gist list -L 50` to see up to 50 Gists.

2. Clone a Gist:

    ```shell
    [wmcdonald@fedora gists ]$ gh gist clone 146b2f19bf4d28252e12c6da168bf956
    Cloning into '146b2f19bf4d28252e12c6da168bf956'...
    remote: Enumerating objects: 13, done.
    remote: Total 13 (delta 0), reused 0 (delta 0), pack-reused 13 (from 1)
    Receiving objects: 100% (13/13), done.
    Resolving deltas: 100% (4/4), done.
    ```

3. List the Gist file contents and update the cloned repository directory name:

    ```
    [wmcdonald@fedora gists ]$ ll
    total 0
    drwxr-xr-x. 1 wmcdonald wmcdonald 66 Nov 18 16:17 146b2f19bf4d28252e12c6da168bf956/

    [wmcdonald@fedora gists ]$ ll 146b2f19bf4d28252e12c6da168bf956/
    total 4.0K
    -rw-r--r--. 1 wmcdonald wmcdonald 2.0K Nov 18 16:17 fedora-container-man-pages.md
    drwxr-xr-x. 1 wmcdonald wmcdonald  138 Nov 18 16:17 .git/

    [wmcdonald@fedora gists ]$ mv 146b2f19bf4d28252e12c6da168bf956/ fedora-container-man-pages/
    renamed '146b2f19bf4d28252e12c6da168bf956/' -> 'fedora-container-man-pages/'
    ```

4. Now you can use your usual update/stage/commit/push Git workflow.

    ```shell
    [wmcdonald@fedora gists ]$ cd fedora-container-man-pages/
    /home/wmcdonald/repos/wmcdonald404/gists/fedora-container-man-pages
    [wmcdonald@fedora fedora-container-man-pages (main ✓)]$ git status
    On branch main
    Your branch is up to date with 'origin/main'.

    nothing to commit, working tree clean
    [wmcdonald@fedora fedora-container-man-pages (main ✓)]$ 
    ```

# Summary
That's it, we can now manage our Gists from the terminal.

# Notes
You can also perform in-place edits to Gists using `gh gist edit <gistid>`.

You can skip a step when cloning the gist using `gh gist clone <gistid> ./repo-path/` to clone to a specific path, removing the need for the rename/move step.

# Further reading
