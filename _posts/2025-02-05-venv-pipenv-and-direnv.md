---
title: "venv, pipenv & direnv"
tags:
- python
- venv
- pipenv
- direnv
---

* TOC
{:toc}

## Overview
I was chatting with someone earlier in the week who thought that managing Python virtual environments (`venvs`) manually would be onerous. I don't do much Python development but it is something I reach for when shell or existing automation tools aren't sufficient. 

I've never found venvs that much of a hassle but thinking about his point of view made me think: "I bet you could make venvs fairly seamless with direnv...". Then I figured: "Others are *bound* to have already done this..." And they have. cf: [Further reading](#further-reading)

Before jumping straight to `pipenv` & `direnv` some context and examples around the tools...

## Background
Some basic definitions on the building blocks:

Most operating systems ship with a Python interpreter (often more than one) and the [Python Standard Libraries](https://docs.python.org/3/library/index.html) pre-packaged (as RPMs, DEBs or whatever package format your distribution favours.)

There are hundreds of thousands of additional Python packages or modules in the ecosystem. Typically these are distributed via the community [Python Package Index (PyPI)](https://pypi.org/). At time of writing this includes:

- 606,397 projects
- 6,561,707 releases
- 13,265,297 files
- 899,744 users

Many of the more popular ones may also be packaged and bundled with your distribution (Fedora, Debian, Arch (btw) etc.). Often, either a package you would like may not be maintained by your distribution vendor, or may not be repackaged as quickly as you would like, lagging behind the PyPY release by months or more.

### pip
[`pip`...](https://pypi.org/project/pip/)

> is the package installer for Python. You can use pip to install packages from the Python Package Index and other indexes.

Running `pip` directly as a root user (without an additional wrapper or safety net) is **NOT recommended** and can break system Python installs and/or cause dependency hell.

Using `pip` as a normal, non-root user will typically install packages into `~/.local/`. This can be *moderately safe* but if you have multiple Python projects with differing version requirements, this can still cause breakage at the user's Python level. (The system Python should be safe so long as you do not `pip install` as root/via sudo.)

This illustrates what `pip install`-ing would look like if run as a normal user. `--dry-run` is used to model the 'what if' scenario without actually changing the target system.
```shell
[wmcdonald@fedora ~ ]$ pip install --dry-run boto
Defaulting to user installation because normal site-packages is not writeable
Collecting boto
  Using cached boto-2.49.0-py2.py3-none-any.whl.metadata (7.3 kB)
Using cached boto-2.49.0-py2.py3-none-any.whl (1.4 MB)
Would install boto-2.49.0
```

This illustrates what `pip install`-ing would look like if run for a package that is already installed, in this case by the system Python pre-packaged by the distribution vendor, Fedora.
```shell
[wmcdonald@fedora ~ ]$ pip install --dry-run boto3
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: boto3 in /usr/lib/python3.13/site-packages (1.36.7)
Requirement already satisfied: botocore<1.37.0,>=1.36.7 in /usr/lib/python3.13/site-packages (from boto3) (1.36.7)
Requirement already satisfied: jmespath<2.0.0,>=0.7.1 in /usr/lib/python3.13/site-packages (from boto3) (1.0.1)
Requirement already satisfied: s3transfer<0.12.0,>=0.11.0 in /usr/lib/python3.13/site-packages (from boto3) (0.11.2)
Requirement already satisfied: python-dateutil<3.0.0,>=2.1 in /usr/lib/python3.13/site-packages (from botocore<1.37.0,>=1.36.7->boto3) (2.8.2)
Requirement already satisfied: urllib3!=2.2.0,<3,>=1.25.4 in /usr/lib/python3.13/site-packages (from botocore<1.37.0,>=1.36.7->boto3) (1.26.20)
Requirement already satisfied: six>=1.5 in /usr/lib/python3.13/site-packages (from python-dateutil<3.0.0,>=2.1->botocore<1.37.0,>=1.36.7->boto3) (1.16.0)

[wmcdonald@fedora ~ ]$ rpm -qf /usr/lib/python3.13/site-packages/boto3/
python3-boto3-1.36.7-1.fc41.noarch

[wmcdonald@fedora ~ ]$ rpm -qi `rpm -qf /usr/lib/python3.13/site-packages/boto3/`
Name        : python3-boto3
Version     : 1.36.7
Release     : 1.fc41
Architecture: noarch
Install Date: Mon 03 Feb 2025 23:20:16 GMT
Group       : Unspecified
Size        : 2167282
License     : Apache-2.0
Signature   : RSA/SHA256, Tue 28 Jan 2025 18:02:25 GMT, Key ID d0622462e99d6ad1
Source RPM  : python-boto3-1.36.7-1.fc41.src.rpm
Build Date  : Tue 28 Jan 2025 15:35:17 GMT
Build Host  : buildvm-a64-32.iad2.fedoraproject.org
Packager    : Fedora Project
Vendor      : Fedora Project
URL         : https://github.com/boto/boto3
Bug URL     : https://bugz.fedoraproject.org/python-boto3
Summary     : The AWS SDK for Python
Description :
Boto3 is the Amazon Web Services (AWS) Software Development Kit (SDK) for
Python, which allows Python developers to write software that makes use of
services like Amazon S3 and Amazon EC2.
```

Beyond `pip install`, there are also:
- `download` - download packages.
- `uninstall` - uninstall packages.
- `freeze` - output installed packages in requirements format.
- `inspect` - inspect the python environment.
- `list` - list installed packages.
- `show` - show information about installed packages.


### venv
[`venv`...](https://docs.python.org/3/library/venv.html)

> supports creating lightweight “virtual environments”, each with their own independent set of Python packages installed in their site directories.

Using the `venv` module, we can create a wrapper, something akin to a chroot or a container, into which we can safely `pip install` dependencies. The `venv` is typically activated / deactivated manually when required. 

For example, first create a directory and switch into it:
```shell
[wmcdonald@fedora ~ ]$ mkdir pipdemo && cd $_
/home/wmcdonald/pipdemo
```

Run a `pip install --dry-run` as we illustrated previously to see that a package/module conflict exists with the system Python and its Boto3 module:
```shell
[wmcdonald@fedora pipdemo ]$ pip install --dry-run boto3
Defaulting to user installation because normal site-packages is not writeable
Requirement already satisfied: boto3 in /usr/lib/python3.13/site-packages (1.36.7)
<snip>
```

Check the packaged Boto3 version in the RPM package database. Run the default system Python, import the boto3 module and enumerate its current version:
```shell
[wmcdonald@fedora ~ ]$ rpm -qf /usr/lib/python3.13/site-packages/boto3/
python3-boto3-1.36.7-1.fc41.noarch

[wmcdonald@fedora pipdemo ]$ python
Python 3.13.1 (main, Dec  9 2024, 00:00:00) [GCC 14.2.1 20240912 (Red Hat 14.2.1-3)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import boto3
>>> print(boto3.__version__)
1.36.7
```

Now, create a Python venv, `python -m venv` invokes the `venv` module, `.venv` is the name of the directory to store the virtual environment and is arbitrary, it's common to use a 'dotfile' to hide this, and the directory name can reflect the purpose of the `venv`, or just be generic. 
```shell
[wmcdonald@fedora pipdemo ]$ python -m venv .venv
```

And inspect its contents, note the `activate` script(s) in the bin directory:
```shell
[wmcdonald@fedora pipdemo ]$ tree -L 3 .venv/
.venv/
├── bin
│   ├── activate
│   ├── activate.csh
│   ├── activate.fish
│   ├── Activate.ps1
│   ├── pip
│   ├── pip3
│   ├── pip3.13
│   ├── python -> /usr/bin/python
│   ├── python3 -> python
│   └── python3.13 -> python
├── include
│   └── python3.13
├── lib
│   └── python3.13
│       └── site-packages
├── lib64 -> lib
└── pyvenv.cfg
```

`source` (or `. `) the activate script to invoke  or 'enter' the virtual environment: 

**Note:** *the prompt will change and prepend the venv name, to indicate the presence of an* active *venv.*
```shell
[wmcdonald@fedora pipdemo ]$ . .venv/bin/activate
(.venv)[wmcdonald@fedora pipdemo ]$ 
```

Now again, run Python and attempt to import Boto3:
```shell
(.venv)[wmcdonald@fedora pipdemo ]$ python
Python 3.13.1 (main, Dec  9 2024, 00:00:00) [GCC 14.2.1 20240912 (Red Hat 14.2.1-3)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import boto3
Traceback (most recent call last):
  File "<python-input-0>", line 1, in <module>
    import boto3
ModuleNotFoundError: No module named 'boto3'
```

We've confirmed that Boto3 "doesn't exist" from the point-of-view of an active `venv`. Now `--dry-run` install Boto3 with `pip`. 

**Note:** *there are no package/module conflicts despite the system Boto3 still being installed/present, this is because it's not present from the point-of-view of the active venv.*
```shell
(.venv)[wmcdonald@fedora pipdemo ]$ pip install --dry-run boto3
Collecting boto3
  Downloading boto3-1.36.13-py3-none-any.whl.metadata (6.7 kB)
<snip>
>Would install boto3-1.36.13 botocore-1.36.13 jmespath-1.0.1 python-dateutil-2.9.0.post0 s3transfer-0.11.2 six-1.17.0 urllib3-2.3.0
```

Now, let's install Boto3 and its dependencies inside the active `venv`:
```shell
(.venv)[wmcdonald@fedora pipdemo ]$ pip install boto3
Collecting boto3
  Using cached boto3-1.36.13-py3-none-any.whl.metadata (6.7 kB)
<snip>
Installing collected packages: urllib3, six, jmespath, python-dateutil, botocore, s3transfer, boto3
Successfully installed boto3-1.36.13 botocore-1.36.13 jmespath-1.0.1 python-dateutil-2.9.0.post0 s3transfer-0.11.2 six-1.17.0 urllib3-2.3.0
```

Start the Python interpreter, import the boto3 module (which is the verion we've just installed using `pip`, into our `venv`). Inspect the Boto3 `__version__` **and** verify the module's `__file__`:

**Note #1:** *it's a later version of Boto3 than the packaged.

**Note #2:** *it's the locally installed Boto3 from the venv.
```shell
(.venv)[wmcdonald@fedora pipdemo ]$ python
Python 3.13.1 (main, Dec  9 2024, 00:00:00) [GCC 14.2.1 20240912 (Red Hat 14.2.1-3)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import boto3
>>> dir(boto3)
['DEFAULT_SESSION', 'NullHandler', 'Session', '__author__', '__builtins__', '__cached__', '__doc__', '__file__', '__loader__', '__name__', '__package__', '__path__', '__spec__', '__version__', '_get_default_session', '_warn_deprecated_python', 'client', 'compat', 'docs', 'exceptions', 'logging', 'resource', 'resources', 'session', 'set_stream_logger', 'setup_default_session', 'utils']
>>> print(boto3.__version__)
1.36.13
>>> print(boto3.__file__)
/home/wmcdonald/pipdemo/.venv/lib64/python3.13/site-packages/boto3/__init__.py
```

Now we can `deactivate` the active `venv` using an alias which is created in the shell environment during the `activate` of the `venv`. And clean up our test directory:
```shell
(.venv)[wmcdonald@fedora pipdemo ]$ deactivate 
[wmcdonald@fedora pipdemo ]$ cd ..
[wmcdonald@fedora ~ ]$ rm -rf pipdemo/
```

### pipenv
[`pipenv`...](https://pypi.org/project/pipenv/)

> is a Python virtualenv management tool that supports a multitude of systems and nicely bridges the gaps between pip, python (using system python, pyenv or asdf) and virtualenv. 

`pipenv` smushes together `pip` and `venv` so you have a single tool that will manage the creation/enablement of `venv`s with the resolution and installation of dependencies.

`pipenv` recommend a [`--user` installation](https://pipenv.pypa.io/en/latest/installation.html) and for Fedora, this is the simplest, safest route. `pipenv` is available pre-packaged as a DEB on both Debian and Ubuntu.

Once installed, create a project directory:
```shell
[vagrant@localhost ~]$ mkdir project-
[vagrant@localhost ~]$ ls -ld project-*
drwxr-xr-x. 1 vagrant vagrant 0 Feb  7 16:33 project-a
```

Verify that the `pip-install-test` module is not present in the default system Python:
```shell
[vagrant@localhost ~]$ python -c 'import pip_install_test'
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import pip_install_test
ModuleNotFoundError: No module named 'pip_install_test'
```

Switch into the test project directory:
```shell
[vagrant@localhost ~]$ cd project-a/
[vagrant@localhost project-a]$ 
```

Install a sample package into the first project directory (output truncated for legibility):
```shell
[vagrant@localhost project-a]$ pipenv install pip-install-test 
Creating a virtualenv for this project
Creating a Pipfile for this project...
Building requirements...
Resolving dependencies...
✔ Success!
To activate this project's virtualenv, run pipenv shell.
Alternatively, run a command inside the virtualenv with pipenv run.
```

Revalidate that the `pip-install-test` module is NOT available:
```shell
[vagrant@localhost project-a]$ python -c 'import pip_install_test'
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import pip_install_test
ModuleNotFoundError: No module named 'pip_install_test'
```

Now a) run with `pipenv run` and b) run through `pipenv shell`:
```shell
[vagrant@localhost project-a]$ pipenv run python -c 'import pip_install_test'
Good job!  You installed a pip module.

Now get back to work!

[vagrant@localhost project-a]$ pipenv shell
Launching subshell in virtual environment...
[vagrant@localhost project-a]$  source /home/vagrant/.local/share/virtualenvs/project-a-vnYESTNH/bin/activate
(project-a) [vagrant@localhost project-a]$ python -c 'import pip_install_test'
Good job!  You installed a pip module.

Now get back to work!
(project-a) [vagrant@localhost project-a]$ 
```

Exit the subshell:
```shell
(project-a) [vagrant@localhost project-a]$ exit
exit
[vagrant@localhost project-a]$ 
```

And now clean up the `pipenv`-created `venv` and the Pipfile and its lockfile.
```shell
[vagrant@localhost project-a]$ pipenv --rm && rm Pipfile*
Removing virtualenv (/home/vagrant/.local/share/virtualenvs/project-a-vnYESTNH)...
[vagrant@localhost project-a]$ 
```

### direnv
[`direnv`...](https://direnv.net/)

> is an extension for your shell. It augments existing shells with a new feature that can load and unload environment variables depending on the current directory.

Once [installed](https://direnv.net/#getting-started), and [hooked into your shell](https://direnv.net/docs/hook.html) `direnv` can be used to trigger specific behaviours when you switch into a specific directory. For example, if you switch into a directory that has a `venv` you could automatically `activate` the `venv` on entry, and `deactivate` if you switch out.

See the `direnv` [quick demo](https://direnv.net/#quick-demo) for a... quick demo.

## How-to
Now we have an understanding of all the component parts, we can use `direnv` to automatically load/unload a `pipenv` on entry into the directory "containing" the `pipenv`-managed `venv` and installed modules .

First create the pipenv
```bash
[vagrant@localhost ~]$ mkdir project-a && cd $_
[vagrant@localhost project-a]$ pipenv install pip-install-test 
```
Configure and enable `direnv` to 'layout' the `pipenv` and run `pipenv graph` to enumerate installed Python module(s):
```bash
[vagrant@localhost project-a]$ echo 'layout pipenv' > .envrc
[vagrant@localhost project-a]$ direnv allow
[vagrant@localhost project-a]$ pipenv graph
pip-install-test==0.5
```
Switch out of the `pipenv` directory, observe that `direnv` unloads.
```bash
[vagrant@localhost project-a]$ cd ~
direnv: unloading
```

Run a test Python module import from the user `${HOME}`, verify that the module **cannot** be found:
```bash 
[vagrant@localhost ~]$ python -c 'import pip_install_test'
Traceback (most recent call last):
  File "<string>", line 1, in <module>
    import pip_install_test
ModuleNotFoundError: No module named 'pip_install_test'
```

Switch back into the directory, observe that `direnv` activates the `pipenv`, re-run the test Python module import and verify that the test module is available:
```bash
[vagrant@localhost ~]$ cd project-a/
direnv: loading ~/project-a/.envrc
direnv: export +PIPENV_ACTIVE +VIRTUAL_ENV ~PATH
[vagrant@localhost project-a]$ python -c 'import pip_install_test'
Good job!  You installed a pip module.

Now get back to work!
```

### Other tools
- Tox
- uv

## Further reading
- [python & pipenv & direnv](https://kylerconway.com/2020/11/25/python-pipenv-direnv/) 
- [Using Python virtual environments with direnv](https://mtudor.xyz/technology/2020/11/1/using-python-virtual-environments-with-direnv)
- https://kellner.io/direnv.html
- https://dev.to/bowmanjd/python-tools-for-managing-virtual-environments-3bko
- https://stackabuse.com/managing-python-environments-with-direnv-and-pyenv/

## Notes
If you try to use `layout python` or `layout python3` instead of `layout pipenv` this will trigger an exception with direnv =< 2.34. This applies in Fedora 41, Debian 12 & Ubuntu 24.04. Bug in-progress: https://bugzilla.redhat.com/show_bug.cgi?id=2344401