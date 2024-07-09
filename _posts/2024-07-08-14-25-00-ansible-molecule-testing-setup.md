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

So this is an attempt to capture the process to configure a new system for Ansible development using Podman as the driver.

## How-to

### Prepping a Virtual Environment

1. Create a Python virtual environment (venv). Activate the venv. Upgrade pip inside the venv. Install Ansible Dev Tools (ADT):

```
wmcdonald@fedora:~/working/ansible-molecule$ python -m venv .venv/adt
wmcdonald@fedora:~/working/ansible-molecule$ . .venv/adt/bin/activate
(adt) wmcdonald@fedora:~/working/ansible-molecule$ pip install --upgrade pip
(adt) wmcdonald@fedora:~/working/ansible-molecule$ pip install ansible-dev-tools
```

### Following the Documentation

Ref: [Getting Started With Molecule](https://ansible.readthedocs.io/projects/molecule/getting-started/)

1. Create a collection:

```
(adt) wmcdonald@fedora:~/working/ansible-molecule$ ansible-galaxy collection init wmcdonald404.testcollection
- Collection wmcdonald404.testcollection was created successfully
```

2. Create a role:

```
(adt) wmcdonald@fedora:~/working/ansible-molecule$ cd wmcdonald404/testcollection/roles/
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection/roles$ ansible-galaxy role init testrole
- Role testrole was created successfully
```

3. Add a task to the role:

```
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection/roles$ cat > ~/working/ansible-molecule/wmcdonald404/testcollection/roles/testrole/tasks/main.yml <<EOF
---
# tasks file for testrole
- name: Debug placeholder task in testrole
  ansible.builtin.debug:
    msg: "This is a task from wmcdonald404.testcollection/testrole."
EOF
```

4. Add a playbook at the root of the collection:

```
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection/roles$ cd ~/working/ansible-molecule/wmcdonald404/testcollection/
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection$ mkdir playbooks

(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection$ cat > ~/working/ansible-molecule/wmcdonald404/testcollection/playbooks/playbook.yml <<EOF
---
- name: Test testrole from within this playbook
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Testing role
      ansible.builtin.include_role:
        name: wmcdonald404.testcollection.testrole
        tasks_from: main.yml
EOF
```

5. Initialise a Molecule scenario in an extensions directory at the root of the role:

```
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection$ mkdir extensions
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection$ cd extensions/
(adt) wmcdonald@fedora:~/working/ansible-molecule/wmcdonald404/testcollection/extensions$ molecule init scenario
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

INFO     Initialized scenario in /home/wmcdonald/working/ansible-molecule/wmcdonald404/testcollection/extensions/molecule/default successfully.

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
- [Developing and Testing Ansible Roles with Molecule and Podman - Part 1](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1/)
- [Testing Ansible Automation with Molecule Pt. 1](https://medium.com/contino-engineering/testing-ansible-automation-with-molecule-pt-1-66ab3ea7a58a)
- [No such command 'role' - Ansible Molecule](https://stackoverflow.com/questions/77244051/no-such-command-role-ansible-molecule)