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


### For a single Role

1. Create a Python virtual environment (venv). Activate the venv. Upgrade pip inside the venv. Install Molecule and the Podman driver:

    ```
    wmcdonald@fedora:~$ python -m venv ~/.venv/molecule.role
    wmcdonald@fedora:~$ . ~/.venv/molecule.role/bin/activate
    (molecule.role) wmcdonald@fedora:~$ pip install --upgrade pip
    (molecule.role) wmcdonald@fedora:~$ pip install molecule-podman
    ```

    **Note:** The virtual environment (venv) will need to be reactivated whenever a terminal/shell session is restarted.

    ```
    wmcdonald@fedora:~$ . ~/.venv/molecule.role/bin/activate
    (molecule.role) wmcdonald@fedora:~$ pip install --upgrade pip
    ```


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

4. Configure Molecule's baseline setup in `molecule.yml`:

    ```
    (molecule.role) wmcdonald@fedora:~$ cat ~/testrole/molecule/default/molecule.yml 
    ---
    dependency:
    name: galaxy
    options:
        requirements-file: requirements.yml
    driver:
    name: podman
    options:
        managed: false
        login_cmd_template: "podman exec -it {instance} bash"
        ansible_connection_options:
        ansible_connection: podman
    platforms:
    - name: centos8
        image: docker.io/centos:8
        privileged: true
        command: /usr/sbin/init
    provisioner:
    name: ansible
    role_name_check: 1
    verifier:
    name: ansible
    ```

5. Define the runtime requirements in `requirements.yml`:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ cat molecule/default/requirements.yml 
    collections:
    - containers.podman
    ```

    > With just the base molecule configuration and its requirements we can now `create`, `list` and `destroy` the scenario.

6. First, `molecule list` to inspect the current status:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule list
    WARNING  Driver podman does not provide a schema.
    INFO     Running default > list
                    ╷             ╷                  ╷               ╷         ╷            
    Instance Name │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged  
    ╶───────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
    ubi9          │ podman      │ ansible          │ default       │ false   │ false      
                    ╵             ╵                  ╵               ╵         ╵            
    ```

7. Next, `molecule create`, to set up the instance(s):

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule create
    WARNING  Driver podman does not provide a schema.
    INFO     default scenario test matrix: dependency, create, prepare
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
    Starting galaxy collection install process
    Nothing to do. All requested collections are already installed. If you want to reinstall them, consider using `--force`.
    INFO     Dependency completed successfully.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > create
    INFO     Sanity checks: 'podman'

    PLAY [Create] ******************************************************************

    TASK [get podman executable path] **********************************************
    ok: [localhost]

    TASK [save path to executable as fact] *****************************************
    ok: [localhost]

    TASK [Set async_dir for HOME env] **********************************************
    ok: [localhost]

    TASK [Log into a container registry] *******************************************
    skipping: [localhost] => (item="ubi9 registry username: None specified") 
    skipping: [localhost]

    TASK [Check presence of custom Dockerfiles] ************************************
    ok: [localhost] => (item=Dockerfile: None specified)

    TASK [Create Dockerfiles from image names] *************************************
    changed: [localhost] => (item="Dockerfile: None specified; Image: registry.access.redhat.com/ubi9/ubi-init")

    TASK [Discover local Podman images] ********************************************
    ok: [localhost] => (item=ubi9)

    TASK [Build an Ansible compatible image] ***************************************
    changed: [localhost] => (item=registry.access.redhat.com/ubi9/ubi-init)

    TASK [Determine the CMD directives] ********************************************
    ok: [localhost] => (item="ubi9 command: None specified")

    TASK [Remove possible pre-existing containers] *********************************
    changed: [localhost]

    TASK [Discover local podman networks] ******************************************
    skipping: [localhost] => (item=ubi9: None specified) 
    skipping: [localhost]

    TASK [Create podman network dedicated to this scenario] ************************
    skipping: [localhost]

    TASK [Create molecule instance(s)] *********************************************
    changed: [localhost] => (item=ubi9)

    TASK [Wait for instance(s) creation to complete] *******************************
    changed: [localhost] => (item=ubi9)

    PLAY RECAP *********************************************************************
    localhost                  : ok=11   changed=5    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

    INFO     Running default > prepare
    WARNING  Skipping, prepare playbook not configured.
    ```

8. Now `molecule list` again, to reflect the created instance(s):

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule list
    WARNING  Driver podman does not provide a schema.
    INFO     Running default > list
                    ╷             ╷                  ╷               ╷         ╷            
    Instance Name │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged  
    ╶───────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
    ubi9          │ podman      │ ansible          │ default       │ true    │ false      
                    ╵             ╵                  ╵               ╵         ╵            
    ```

9. Verify we can `molecule login` to the instance, and check something that would appear distinct from the host we're running on currently (e.g. this be being run on Fedora where `/etc/redhat-release` would differ significantly):

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule login
    WARNING  Driver podman does not provide a schema.
    INFO     Running default > login
    [root@ubi9 /]# cat /etc/redhat-release 
    Red Hat Enterprise Linux release 9.4 (Plow)
    [root@ubi9 /]# ps -ef
    UID          PID    PPID  C STIME TTY          TIME CMD
    root           1       0  0 21:46 ?        00:00:00 bash -c while true; do sleep 10000; done
    root           2       1  0 21:46 ?        00:00:00 /usr/bin/coreutils --coreutils-prog-shebang=sleep /usr/bin/sleep 10000
    root          14       0  0 21:49 pts/0    00:00:00 bash
    root          26      14  0 21:49 pts/0    00:00:00 ps -ef
    ```

10. Finally, destroy the instance to clean up after ourselves:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule destroy
    WARNING  Driver podman does not provide a schema.
    INFO     default scenario test matrix: dependency, cleanup, destroy
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
    Starting galaxy collection install process
    Nothing to do. All requested collections are already installed. If you want to reinstall them, consider using `--force`.
    INFO     Dependency completed successfully.
    WARNING  Skipping, missing the requirements file.
    INFO     Running default > cleanup
    WARNING  Skipping, cleanup playbook not configured.
    INFO     Running default > destroy
    INFO     Sanity checks: 'podman'

    PLAY [Destroy] *****************************************************************

    TASK [Set async_dir for HOME env] **********************************************
    ok: [localhost]

    TASK [Destroy molecule instance(s)] ********************************************
    changed: [localhost] => (item={'image': 'registry.access.redhat.com/ubi9/ubi-init', 'name': 'ubi9', 'privileged': True})

    TASK [Wait for instance(s) deletion to complete] *******************************
    FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (300 retries left).
    FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (299 retries left).
    changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': 'j85882995859.23279', 'results_file': '/home/wmcdonald/.ansible_async/j85882995859.23279', 'changed': True, 'item': {'image': 'registry.access.redhat.com/ubi9/ubi-init', 'name': 'ubi9', 'privileged': True}, 'ansible_loop_var': 'item'})

    PLAY RECAP *********************************************************************
    localhost                  : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    INFO     Pruning extra files from scenario ephemeral directory
    ```

# Refining creation and testing:

1. Configure specifc steps for the create setup in `create.yml`:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ cat molecule/default/create.yml 
    - name: Create
      hosts: localhost
      gather_facts: false
      vars:
        molecule_inventory:
          all:
            hosts: {}
            children:
              molecule:
                hosts: {}

      tasks:
        - name: Create a container
          containers.podman.podman_container:
            name: { "{{ item.name }}" }
            image: "{{ item.image }}"
            privileged: "{{ item.privileged | default(omit) }}"
            volumes: "{{ item.volumes | default(omit) }}"
            capabilities: "{{ item.capabilities | default(omit) }}"
            systemd: "{{ item.systemd | default(omit) }}"
            state: started
            command: "{{ item.command | default('sleep 1d') }}"
            # bash -c "while true; do sleep 10000; done"
            log_driver: json-file
          register: result
          loop: "{{ molecule_yml.platforms }}"

        - name: Print some info
          ansible.builtin.debug:
            msg: "{{ result.results }}"

        - name: Fail if container is not running
          when: >
            item.container.State.ExitCode != 0 or
            not item.container.State.Running
          ansible.builtin.include_tasks:
            file: tasks/create-fail.yml
          loop: "{{ result.results }}"
          loop_control:
            label: "{{ item.container.Name }}"

        - name: Add container to molecule_inventory
          vars:
            inventory_partial_yaml: |
            all:
              children:
              molecule:
                hosts:
                  "{{ item.name }}":
                      ansible_connection: containers.podman.podman
          ansible.builtin.set_fact:
            molecule_inventory: >
              {{ molecule_inventory | combine(inventory_partial_yaml | from_yaml, recursive=true) }}
          loop: "{{ molecule_yml.platforms }}"
          loop_control:
            label: "{{ item.name }}"

        - name: Dump molecule_inventory
          ansible.builtin.copy:
            content: |
              {{ molecule_inventory | to_yaml }}
            dest: "{{ molecule_ephemeral_directory }}/inventory/molecule_inventory.yml"
            mode: "0600"

        - name: Force inventory refresh
          ansible.builtin.meta: refresh_inventory

        - name: Fail if molecule group is missing
          ansible.builtin.assert:
            that: "'molecule' in groups"
            fail_msg: |
              molecule group was not found inside inventory groups: {{ groups }}
          run_once: true # noqa: run-once[task]

    # we want to avoid errors like "Failed to create temporary directory"
    - name: Validate that inventory was refreshed
      hosts: molecule
      gather_facts: false
      tasks:
        - name: Check uname
          ansible.builtin.raw: uname -a
          register: result
          changed_when: false

        - name: Display uname info
          ansible.builtin.debug:
            msg: "{{ result.stdout }}"
    ```

2. Configure the converge stage:

    ```
    (molecule.role) wmcdonald@fedora:~$ cat ~/testrole/molecule/default/converge.yml 
    ---
    - name: Converge
      hosts: all
      roles:
        - role: testrole
    ```

3. Add the verify tests:

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

4. Add a default task to the role's main.yml:

    ```
    ---
    - name: Molecule Hello World!
      ansible.builtin.debug:
        msg: Hello, World!
    ```


5. Run the test scenario@

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