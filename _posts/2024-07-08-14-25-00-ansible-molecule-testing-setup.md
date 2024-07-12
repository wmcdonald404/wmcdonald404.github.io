---
title: "Ansible Molecule Setup (WIP)"
date: 2024-07-08 14-25-00
tags:
- redhat
- ubuntu
- ansible
- molecule
- testing
---

## Overview
The Ansible SDLC landscape has changed *significantly* over the last 8+ years with the addition of Ansible Development Tools (ADT), Execution Environments, Ansible Navigator, Ansible Creator, Devcontainers etc. As a result, setting up an environment for playbook, role or collection testing can be a rapidly moving target.

While setting up some baseline prequisites to do some Ansible role testing using Molecule, I was working through the setup steps from [this blog post](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1/). It's from 2020 which doesn't feel like it was that long ago, and yet it's nearly 4 years at time of writing, and some of the steps no longer work. For example `molecule init role <rolename>` fails because [this functionality has been removed](https://github.com/ansible/molecule/pull/3959). 

So this is an attempt to capture the process to configure a new system for Ansible development using Podman as the container runtime.

## How-to

### Prepping a Virtual Environment

1. Create a Python virtual environment (venv). Activate the venv. Upgrade pip inside the venv. Install Ansible Dev Tools (ADT):

    ```
    wmcdonald@fedora:~$ mkdir ~/adt
    wmcdonald@fedora:~$ cd ~/adt/
    wmcdonald@fedora:~/adt$ python -m venv .venv/adt
    wmcdonald@fedora:~/adt$ . ~/adt/.venv/adt/bin/activate
    (adt) wmcdonald@fedora:~/adt$ pip install --upgrade pip
    (adt) wmcdonald@fedora:~/adt$ pip install ansible-dev-tools
    ```

2. Verify the version of base tooling:

    ```
    (adt) wmcdonald@fedora:~/adt$ which python && python --version
    ~/adt/.venv/adt/bin/python
    Python 3.12.4

    (adt) wmcdonald@fedora:~/adt$ which pip && pip --version
    ~/adt/.venv/adt/bin/pip
    pip 24.1.2 from /home/wmcdonald/adt/.venv/adt/lib64/python3.12/site-packages/pip (python 3.12)

    (adt) wmcdonald@fedora:~/adt$ which ansible && ansible --version
    ~/adt/.venv/adt/bin/ansible
    ansible [core 2.17.1]
      config file = /home/wmcdonald/.ansible.cfg
      configured module search path = ['/home/wmcdonald/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
      ansible python module location = /home/wmcdonald/adt/.venv/adt/lib64/python3.12/site-packages/ansible
      ansible collection location = /home/wmcdonald/.ansible/collections:/usr/share/ansible/collections
      executable location = /home/wmcdonald/adt/.venv/adt/bin/ansible
      python version = 3.12.4 (main, Jun  7 2024, 00:00:00) [GCC 14.1.1 20240607 (Red Hat 14.1.1-5)] (/home/wmcdonald/adt/.venv/adt/bin/python)
      jinja version = 3.1.4
      libyaml = True

    (adt) wmcdonald@fedora:~/adt$ which molecule && molecule --version
    ~/adt/.venv/adt/bin/molecule
    molecule 24.7.0 using python 3.12 
        ansible:2.17.1
        default:24.7.0 from molecule
    ```

**Note:** Whenever you're working through any subsequent steps, if you have started a new terminal / shell session, you will need to reactivate the Python virtual environment (venv).

    ```
    wmcdonald@fedora:~$ . ~/adt/.venv/adt/bin/activate
    (adt) wmcdonald@fedora:~$ 
    ```

### Following the Documentation

The documentation, [Getting Started With Molecule](https://ansible.readthedocs.io/projects/molecule/getting-started/), walks through the end-to-end process of setting up Molecule testing inside a collection. Ideally we want to start with something simpler/narrower, like a role, but in order to understand the moving parts following the documentation beginning to end is a reasonable place to start.

1. Create a collection, review the created tree:

    ```
    (adt) wmcdonald@fedora:~/adt$ ansible-galaxy collection init wmcdonald.testcollection
    - Collection wmcdonald.testcollection was created successfully

    (adt) wmcdonald@fedora:~/adt$ tree wmcdonald/
    wmcdonald/
    └── testcollection
        ├── docs
        ├── galaxy.yml
        ├── meta
        │   └── runtime.yml
        ├── plugins
        │   └── README.md
        ├── README.md
        └── roles

    6 directories, 4 files
    ```

2. Create a role:

    ```
    (adt) wmcdonald@fedora:~/adt$ cd ~/adt/wmcdonald/testcollection/roles/
    (adt) wmcdonald@fedora:~/adt/wmcdonald/testcollection/roles$ ansible-galaxy role init testrole
    - Role testrole was created successfully
    
    (adt) wmcdonald@fedora:~/adt/wmcdonald/testcollection/roles$ tree testrole/
    testrole/
    ├── defaults
    │   └── main.yml
    ├── files
    ├── handlers
    │   └── main.yml
    ├── meta
    │   └── main.yml
    ├── README.md
    ├── tasks
    │   └── main.yml
    ├── templates
    ├── tests
    │   ├── inventory
    │   └── test.yml
    └── vars
        └── main.yml

    9 directories, 8 files
    ```

3. Add a task to the role, so there's an action to test when running the role:

    ```
    (adt) wmcdonald@fedora:~/adt/wmcdonald/testcollection/roles$ cd ~/adt/
    (adt) wmcdonald@fedora:~/adt$ cat > ~/adt/wmcdonald/testcollection/roles/testrole/tasks/main.yml <<EOF
    ---
    # tasks file for testrole
    - name: Debug placeholder task in testrole
      ansible.builtin.debug:
        msg: "This is a task from wmcdonald.testcollection/testrole."
    EOF
    ```

4. Add a playbook at the root of the collection:

    ```
    (adt) wmcdonald@fedora:~/adt$ mkdir ~/adt/wmcdonald/testcollection/playbooks

    (adt) wmcdonald@fedora:~/adt$ cat > ~/adt/wmcdonald/testcollection/playbooks/playbook.yml <<EOF
    ---
    - name: Test testrole from within this playbook
      hosts: localhost
      gather_facts: false
      tasks:
        - name: Testing role
          ansible.builtin.include_role:
            name: wmcdonald.testcollection/testrole
            tasks_from: main.yml
    EOF
    ```

5. Initialise a Molecule scenario in an extensions directory at the root of the role:

    ```
    (adt) wmcdonald@fedora:~/adt$ mkdir ~/adt/wmcdonald/testcollection/extensions

    (adt) wmcdonald@fedora:~/adt$ cd wmcdonald/testcollection/extensions/

    (adt) wmcdonald@fedora:~/adt/wmcdonald/testcollection/extensions$ molecule init scenario 
    INFO     Initializing new scenario default...

    PLAY [Create a new molecule scenario] ******************************************

    TASK [Check if destination folder exists] **************************************
    changed: [localhost]

    TASK [Check if destination folder is empty] ************************************
    ok: [localhost]

    TASK [Fail if destination folder is not empty] *********************************
    skipping: [localhost]

    TASK [Expand templates] ********************************************************
    changed: [localhost] => (item=molecule/default/converge.yml)
    changed: [localhost] => (item=molecule/default/create.yml)
    changed: [localhost] => (item=molecule/default/destroy.yml)
    changed: [localhost] => (item=molecule/default/molecule.yml)

    PLAY RECAP *********************************************************************
    localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Initialized scenario in /home/wmcdonald/adt/wmcdonald/testcollection/extensions/molecule/default successfully.
    ```

6. Check the syntax:

    ```
    (adt) wmcdonald@fedora:~/adt/wmcdonald/testcollection/extensions$ molecule syntax
    INFO     default scenario test matrix: syntax
    INFO     Performing prerun with role_name_check=0...
    INFO     Running default > syntax

    playbook: /home/wmcdonald/adt/wmcdonald/testcollection/extensions/molecule/default/converge.yml
    ```

7. Run a full-test cycle:

    ```
    (adt) wmcdonald@fedora:~/adt/wmcdonald/testcollection/extensions$ molecule test
    INFO     default scenario test matrix: dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
    INFO     Performing prerun with role_name_check=0...
    INFO     Running default > dependency
    WARNING  Skipping, missing the requirements file.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy

    PLAY [Destroy] *****************************************************************

    TASK [Populate instance config] ************************************************
    ok: [localhost]

    TASK [Dump instance config] ****************************************************
    skipping: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Running default > syntax

    playbook: /home/wmcdonald/adt/wmcdonald/testcollection/extensions/molecule/default/converge.yml
    INFO     Running default > create

    PLAY [Create] ******************************************************************

    TASK [Populate instance config dict] *******************************************
    skipping: [localhost]

    TASK [Convert instance config dict to a list] **********************************
    skipping: [localhost]

    TASK [Dump instance config] ****************************************************
    skipping: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=0    changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    INFO     Running default > converge

    PLAY [Converge] ****************************************************************

    TASK [Replace this task with one that validates your content] ******************
    ok: [instance] => {
        "msg": "This is the effective test"
    }

    PLAY RECAP *********************************************************************
    instance                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Running default > idempotence

    PLAY [Converge] ****************************************************************

    TASK [Replace this task with one that validates your content] ******************
    ok: [instance] => {
        "msg": "This is the effective test"
    }

    PLAY RECAP *********************************************************************
    instance                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Idempotence completed successfully.
    INFO     Running default > side_effect
    WARNING  Skipping, side effect playbook not configured.
    INFO     Running default > verify
    INFO     Running Ansible Verifier
    WARNING  Skipping, verify action has no playbook.
    INFO     Verifier completed successfully.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy

    PLAY [Destroy] *****************************************************************

    TASK [Populate instance config] ************************************************
    ok: [localhost]

    TASK [Dump instance config] ****************************************************
    skipping: [localhost]

    PLAY RECAP *********************************************************************
    localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory
    ```

### For a single Role


2. Create a test role

```
(adt) wmcdonald@fedora:~/working/ansible-molecule$ ansible-galaxy role init wmcdonald404.testrole
- Role wmcdonald404.testrole was created successfully
(adt) wmcdonald@fedora:~/working/ansible-molecule$ tree wmcdonald404.testrole/
wmcdonald404.testrole/
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

9 directories, 8 files
```

3. Add a molecule scenario 

```
(adt) wmcdonald@fedora:~/working/ansible-molecule$ cd wmcdonald404.testrole/
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404.testrole$ molecule init scenario 
INFO     Initializing new scenario default...

PLAY [Create a new molecule scenario] ******************************************

TASK [Check if destination folder exists] **************************************
changed: [localhost]

TASK [Check if destination folder is empty] ************************************
ok: [localhost]

TASK [Fail if destination folder is not empty] *********************************
skipping: [localhost]

TASK [Expand templates] ********************************************************
changed: [localhost] => (item=molecule/default/converge.yml)
changed: [localhost] => (item=molecule/default/create.yml)
changed: [localhost] => (item=molecule/default/destroy.yml)
changed: [localhost] => (item=molecule/default/molecule.yml)

PLAY RECAP *********************************************************************
localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Initialized scenario in /home/wmcdonald/working/ansible-molecule/wmcdonald404.testrole/molecule/default successfully.
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404.testrole$ tree .
.
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── molecule
│   └── default
│       ├── converge.yml
│       ├── create.yml
│       ├── destroy.yml
│       └── molecule.yml
├── README.md
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

11 directories, 12 files
```


## References
- [Introducing Ansible Molecule with Ansible Automation Platform](https://developers.redhat.com/articles/2023/09/13/introducing-ansible-molecule-ansible-automation-platform#getting_started_with_molecule_developer_preview)
- [Developing and Testing Ansible Roles with Molecule and Podman - Part 1](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1/)
- [Testing Ansible Automation with Molecule Pt. 1](https://medium.com/contino-engineering/testing-ansible-automation-with-molecule-pt-1-66ab3ea7a58a)
- [No such command 'role' - Ansible Molecule](https://stackoverflow.com/questions/77244051/no-such-command-role-ansible-molecule)