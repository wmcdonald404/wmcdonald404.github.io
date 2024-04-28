---
title: Gitlab Group and Project Tree Walk
date: 2024-04-28 16:34:48
tags:
- gitlab 
- api
---

## Overview
Many enterprises using Gitlab will end up with a deeply nested hierarchy of groups and projects (aka repositories) reflecting their organisation, team and application structures. (This is a symptom of [Conway's Law](https://psychsafety.co.uk/psychological-safety-conways-law/) in action.)

The larger the organisation, or the more convoluted and granular groups and projects are _for reasons_, this can become complex to navigate.


## Background
The UI is a useful tool in terms of visualising this, identifying group branches to clone children of using either an IDE, or the Gitlab CLI (`glab`).

However for users more comfortable with command line tools, it's useful to be able to visualise that structure in the terminal. Working in an environment that has a broad and deeply-nested hierarchy, and the Gitlab CLI not providing a native tree capability currently, I wanted something that a) helped me understand the API a little better and b) helped me and other members of the team comprehend the group and project topology in order to know which bits to clone.

The script is shared at:
- [wmcdonald404-scripts/python/gitlab-tree/glgtree](https://github.com/wmcdonald404/wmcdonald404-scripts/blob/master/python/gitlab-tree/glgtree)
- [glgtree, raw](https://raw.githubusercontent.com/wmcdonald404/wmcdonald404-scripts/master/python/gitlab-tree/glgtree)

## How-to
1. Install the Gitlab Python API

    - *Fedora:* 
        `$ sudo dnf -y install python3-gitlab`
    - *Amazon Linux 2023:* 
        `TBC`
    - *Windows:* 
        `TBC`

2. Grab the `glgtree` script and make it executable:

    ```
    $ mkdir ~/.local/bin/
    $ curl -s https://raw.githubusercontent.com/wmcdonald404/wmcdonald404-scripts/master/python/gitlab-tree/glgtree -o ~/.local/bin/glgtree
    $ chmod u+x $_
    ```

3. Set your [Gitlab Personal Access Token (PAT)](https://gitlab.com/-/user_settings/personal_access_tokens):

    ```
    $ export GITLAB_TOKEN=glpat-<PATID>
    ```
    *Note:* replace <PATID> with your own token name

4. Now we can list groups and repositories

    ```
    wmcdonald@fedora:~$ glgtree -g 86427305
    📁 demo-topgroup (86427305)
    ├── 📁 demo-subgroup1 (86427310)
    │   ├── 📁 subgroup1-team1 (86427383)
    │   │   ├── 📁 team1-squad-a (86427510)
    │   │   │   ├── 📗 squad-a-memelords (57340128)
    │   │   │   ├── 📗 squad-a-app1 (57340122)
    │   │   │   ├── 📗 squad-a-build (57340114)
    │   │   │   └── 📗 squad-a-infra (57340105)
    │   │   ├── 📁 team1-squad-b (86427519)
    │   │   ├── 📗 team1-repo2 (57339925)
    │   │   └── 📗 team1-repo1 (57339921)
    │   └── 📁 subgroup1-team2 (86427393)
    │       ├── 📗 team2-repo2 (57339964)
    │       └── 📗 team2-repo1 (57339959)
    └── 📁 demo-subgroup2 (86427321)
        ├── 📗 subgroup2-app2 (57339899)
        └── 📗 subgroup2-app1 (57339887)
    ```

## Summary
We can now visualise our group and repository hierarchy and identify groups vs. repositories. We can then take a group or repository ID and clone it and its children using glab, the API or other means.

## Further reading
- [Gitlab CLI](https://gitlab.com/gitlab-org/cli#installation)
