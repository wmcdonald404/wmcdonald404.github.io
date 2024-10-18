---
title: "Ansible Molecule Setup"
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
    (molecule.role) wmcdonald@fedora:~$ 
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
      - name: ubi9
        image: registry.access.redhat.com/ubi9/ubi-init
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
    ╶─────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
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
    ╶─────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
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

10. Finally, `molecule destroy` to tear down the instance and clean up:

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

### Refining creation and testing:

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
            name: {% raw %}"{{ item.name }}"{% endraw %} 
            image: {% raw %}"{{ item.image }}"{% endraw %} 
            privileged: {% raw %}"{{ item.privileged | default(omit) }}"{% endraw %} 
            volumes: {% raw %}"{{ item.volumes | default(omit) }}"{% endraw %} 
            capabilities: {% raw %}"{{ item.capabilities | default(omit) }}"{% endraw %} 
            systemd: {% raw %}"{{ item.systemd | default(omit) }}"{% endraw %} 
            state: started
            command: {% raw %}"{{ item.command | default('sleep 1d') }}"{% endraw %} 
            # bash -c "while true; do sleep 10000; done"
            log_driver: json-file
          register: result
          loop: {% raw %}"{{ molecule_yml.platforms }}"{% endraw %} 

        - name: Print some info
          ansible.builtin.debug:
            msg: {% raw %}"{{ result.results }}"{% endraw %}

        - name: Fail if container is not running
          when: >
            item.container.State.ExitCode != 0 or
            not item.container.State.Running
          ansible.builtin.include_tasks:
            file: tasks/create-fail.yml
          loop: {% raw %}"{{ result.results }}"{% endraw %}
          loop_control:
            label: {% raw %}"{{ item.container.Name }}"{% endraw %}

        - name: Add container to molecule_inventory
          vars:
            inventory_partial_yaml: |
            all:
              children:
              molecule:
                hosts:
                  {% raw %}"{{ item.name }}"{% endraw %}:
                      ansible_connection: containers.podman.podman
          ansible.builtin.set_fact:
            molecule_inventory: >
              {% raw %}{{ molecule_inventory | combine(inventory_partial_yaml | from_yaml, recursive=true) }}{% endraw %}
          loop: {% raw %}"{{ molecule_yml.platforms }}"{% endraw %}
          loop_control:
            label: {% raw %}"{{ item.name }}"{% endraw %}

        - name: Dump molecule_inventory
          ansible.builtin.copy:
            content: |
              {% raw %}{{ molecule_inventory | to_yaml }}{% endraw %}
            dest: {% raw %}"{{ molecule_ephemeral_directory }}{% endraw %}/inventory/molecule_inventory.yml"
            mode: "0600"

        - name: Force inventory refresh
          ansible.builtin.meta: refresh_inventory

        - name: Fail if molecule group is missing
          ansible.builtin.assert:
            that: "'molecule' in groups"
            fail_msg: |
              molecule group was not found inside inventory groups: {% raw %}{{ groups }}{% endraw %}
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
            msg: {% raw %}"{{ result.stdout }}"{% endraw %}
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

5. Run the test scenario, note the test failure:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule test
    <output truncated>

    TASK [Check if httpd is installed] *********************************************
    fatal: [ubi9]: FAILED! => {"changed": false, "cmd": ["rpm", "-q", "httpd"], "delta": "0:00:00.010675", "end": "2024-10-09 10:35:17.430486", "failed_when_result": true, "msg": "non-zero return code", "rc": 1, "start": "2024-10-09 10:35:17.419811", "stderr": "", "stderr_lines": [], "stdout": "package httpd is not installed", "stdout_lines": ["package httpd is not installed"]}

    PLAY RECAP *********************************************************************
    ubi9                       : ok=1    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
    ```

6. Update the role's main.yml to include something more useful and testable:

    ```
    ---
    - name: Molecule Hello World!
      ansible.builtin.debug:
        msg: Hello, World!

    - name: Install HTTP Server
      ansible.builtin.package:
        name: httpd
    ```

7. Run the test scenario again, note the test passes:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule test
    <output truncated>

    TASK [Check if httpd is installed] *********************************************
    ok: [ubi9]

    PLAY RECAP *********************************************************************
    ubi9                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

### Running individual stages:

We can now run individual steps, giving fine-grained control over execution and the ability to shorten feedback loops during testing cycles.

1. Review the output from `molecule --help` note the steps that run end-to-end during `molecule test`:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule --help
    Usage: molecule [OPTIONS] COMMAND [ARGS]...

    Molecule aids in the development and testing of Ansible roles.

    To enable autocomplete for a supported shell execute command below after replacing SHELL with either bash, zsh, or fish:

        eval "$(_MOLECULE_COMPLETE=SHELL_source molecule)"

    Options:
    --debug / --no-debug    Enable or disable debug mode. Default is disabled.
    -v, --verbose           Increase Ansible verbosity level. Default is 0.
    -c, --base-config TEXT  Path to a base config (can be specified multiple times). If provided, Molecule will first load and deep merge the configurations
                            in the specified order, and deep merge each scenario's molecule.yml on top. By default Molecule is looking for
                            '.config/molecule/config.yml' in current VCS repository and if not found it will look in user home. (None).
    -e, --env-file TEXT     The file to read variables from when rendering molecule.yml. (.env.yml)
    --version
    --help                  Show this message and exit.

    Commands:
    check        Use the provisioner to perform a Dry-Run (destroy, dependency, create, prepare, converge).
    cleanup      Use the provisioner to cleanup any changes.
    converge     Use the provisioner to configure instances (dependency, create, prepare converge).
    create       Use the provisioner to start the instances.
    dependency   Manage the role's dependencies.
    destroy      Use the provisioner to destroy the instances.
    drivers      List drivers.
    idempotence  Use the provisioner to configure the instances.
    init         Initialize a new scenario.
    list         List status of instances.
    login        Log in to one instance.
    matrix       List matrix of steps used to test instances.
    prepare      Use the provisioner to prepare the instances into a particular starting state.
    reset        Reset molecule temporary folders.
    side-effect  Use the provisioner to perform side-effects to the instances.
    syntax       Use the provisioner to syntax check the role.
    test         Test (dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy).
    verify       Run automated tests against instances.
    ```

    > **Note:** `molecule test` runs the full suite of `dependency, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy`

2. Start from a clean state

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule destroy
    ```

3. Review the status

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

4. Create the target testing environment

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule create
    ```

5. Review the status

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

6. 'Converge' the testing environment by applying the role

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule converge
    ```

7. Review the status

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule list
    WARNING  Driver podman does not provide a schema.
    INFO     Running default > list
                    ╷             ╷                  ╷               ╷         ╷            
      Instance Name │ Driver Name │ Provisioner Name │ Scenario Name │ Created │ Converged  
    ╶───────────────┼─────────────┼──────────────────┼───────────────┼─────────┼───────────╴
      ubi9          │ podman      │ ansible          │ default       │ true    │ true       
                    ╵             ╵                  ╵               ╵         ╵            
    ```

8. 'Verify' to run the tests against the prepared environment

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule verify

    TASK [Check if httpd is installed] *********************************************
    ok: [ubi9]

    PLAY RECAP *********************************************************************
    ubi9                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

    ```

9. Clean up:

    ```
    (molecule.role) wmcdonald@fedora:~/testrole$ molecule destroy
    ```



## References
- [Introducing Ansible Molecule with Ansible Automation Platform](https://developers.redhat.com/articles/2023/09/13/introducing-ansible-molecule-ansible-automation-platform#getting_started_with_molecule_developer_preview)
- [Developing and Testing Ansible Roles with Molecule and Podman - Part 1](https://www.ansible.com/blog/developing-and-testing-ansible-roles-with-molecule-and-podman-part-1/)
- [Testing Ansible Automation with Molecule Pt. 1](https://medium.com/contino-engineering/testing-ansible-automation-with-molecule-pt-1-66ab3ea7a58a)
- [No such command 'role' - Ansible Molecule](https://stackoverflow.com/questions/77244051/no-such-command-role-ansible-molecule)