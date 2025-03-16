---
title: "VSCode Remote Devcontainer"
tags:
- vscode
- devcontainer
- ssm
- ssh
---

## Overview


## Prerequisites



## Connecting
1. Open VSCode
2. Connect to the remote system
3. Connect VSCode to the remote
4. If they are not present, install the remote prerequisites

    ```
    $ sudo apt-get update
    $ sudo apt -y install git docker.io
    $ sudo usermod -aG docker admin
    ```

5. `kill` the remote VSCode server to reinvoke a login shell and reread supplemental group membership. Reconnect and verify membership of the `docker` group

    **Note:** see [this issue](https://github.com/microsoft/vscode-remote-release/issues/5813) for further detail.
    ```
    $ pkill -f .vscode-server
    $ groups
    admin adm dialout cdrom floppy sudo audio dip video plugdev docker
    ```

6. Set up the VSCode workspace

    ```
    $ mkdir ~/workspace
    $ cd ~/workspace/
    $ git clone https://github.com/wmcdonald404/devcontainer-python
    ```

7. In VSCode, `CTRL`-`SHIFT`-`P` and select `Dev Containers: Clone Repository in Container Volume...`, clone the repository into a new running devcontainer on the remote host.


## Further reading
