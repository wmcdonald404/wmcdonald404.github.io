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

**Note:** The virtual environment (venv) will need to be reactivated whenever a terminal/shell session is restarted.

    wmcdonald@fedora:~$ . ~/adt/.venv/adt/bin/activate
    (adt) wmcdonald@fedora:~$ 

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

1. Create a Python virtual environment (venv). Activate the venv. Upgrade pip inside the venv. Install Molecule and the Podman driver:

```
wmcdonald@fedora:~$ python -m venv ~/.venv/molecule.role
wmcdonald@fedora:~$ . ~/.venv/molecule.role/bin/activate
(molecule.role) wmcdonald@fedora:~$ pip install --upgrade pip
(molecule.role) wmcdonald@fedora:~$ pip install molecule-podman
```

**Note:** The virtual environment (venv) will need to be reactivated whenever a terminal/shell session is restarted.

    wmcdonald@fedora:~$ . ~/.venv/molecule.role/bin/activate
    (molecule.role) wmcdonald@fedora:~$ pip install --upgrade pip


2. Create a test role

```
(molecule.role) wmcdonald@fedora:~$ ansible-galaxy role init testrole
- Role testrole was created successfully
```

3. Add a molecule scenario 

```
(molecule.role) wmcdonald@fedora:~/testrole$ molecule init scenario
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

INFO     Initialized scenario in /home/wmcdonald/testrole/molecule/default successfully.

```

4. Configure the Molecule YAML:

```
(molecule.role) wmcdonald@fedora:~$ cat ~/testrole/molecule/default/molecule.yml 
---
dependency:
  name: galaxy
driver:
  name: podman
platforms:
  - name: instance
    image: docker.io/centos:8
    privileged: true
    command: /usr/sbin/init
provisioner:
  name: ansible
role_name_check: 1
verifier:
  name: ansible
```

5. Configure the converge stage:

```
(molecule.role) wmcdonald@fedora:~$ cat ~/testrole/molecule/default/converge.yml 
---
- name: Converge
  hosts: all
  roles:
    - role: testrole

```

6. Add the verify tests:

```
(molecule.role) wmcdonald@fedora:~$ cat ~/testrole/molecule/default/verify.yml
---
- name: Verify
  hosts: all
  tasks:
    - name: Check if httpd is installed
      command: rpm -q httpd
      register: result
      failed_when: result.rc != 0
      changed_when: false
```

7. Run the test scenario@

```
(molecule.role) wmcdonald@fedora:~/testrole$ molecule test
WARNING  Driver podman does not provide a schema.
INFO     default scenario test matrix: dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=1...
WARNING  Computed fully qualified role name of testrole does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead

Namespace: https://galaxy.ansible.com/docs/contributing/namespaces.html#galaxy-namespace-limitations
Role: https://galaxy.ansible.com/docs/contributing/creating_role.html#role-names

As an alternative, you can add 'role-name' to either skip_list or warn_list.

INFO     Running default > dependency
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy
INFO     Sanity checks: 'podman'

PLAY [Destroy] *****************************************************************

TASK [Populate instance config] ************************************************
ok: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running default > syntax

playbook: /home/wmcdonald/testrole/molecule/default/converge.yml
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

TASK [Gathering Facts] *********************************************************
fatal: [instance]: UNREACHABLE! => {"changed": false, "msg": "Failed to create temporary directory. In some cases, you may have been able to authenticate and did not have permissions on the target directory. Consider changing the remote tmp path in ansible.cfg to a path rooted in \"/tmp\", for more error information use -vvv. Failed command was: ( umask 77 && mkdir -p \"` echo ~/.ansible/tmp `\"&& mkdir \"` echo ~/.ansible/tmp/ansible-tmp-1721482015.978296-9663-236119934532429 `\" && echo ansible-tmp-1721482015.978296-9663-236119934532429=\"` echo ~/.ansible/tmp/ansible-tmp-1721482015.978296-9663-236119934532429 `\" ), exited with result 125", "unreachable": true}

PLAY RECAP *********************************************************************
instance                   : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0

CRITICAL Ansible return code was 4, command was: ansible-playbook --inventory /home/wmcdonald/.cache/molecule/testrole/default/inventory --skip-tags molecule-notest,notest /home/wmcdonald/testrole/molecule/default/converge.yml
WARNING  An error occurred during the test sequence action: 'converge'. Cleaning up.
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


## References
- [Introducing Ansible Molecule with Ansible Automation Platform](https://developers.redhat.com/articles/2023/09/13/introducing-ansible-molecule-ansible-automation-platform#getting_started_with_molecule_developer_preview)
- [Developing and Testing Ansible Roles with Molecule and Podman - Part 1](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1/)
- [Testing Ansible Automation with Molecule Pt. 1](https://medium.com/contino-engineering/testing-ansible-automation-with-molecule-pt-1-66ab3ea7a58a)
- [No such command 'role' - Ansible Molecule](https://stackoverflow.com/questions/77244051/no-such-command-role-ansible-molecule)