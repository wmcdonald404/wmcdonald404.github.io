---
title: "Python - Jinja - Using Jinja with shell variables from the CLI"
date: 2024-03-23 22:47:00
---

## Overview
To quote the [upstream documentation](https://jinja.palletsprojects.com/en/3.1.x/):
> Jinja is a fast, expressive, extensible templating engine. Special placeholders in the template allow writing code similar to Python syntax. Then the template is passed data to render the final document.
And more verbosely:
> A Jinja template is simply a text file. Jinja can generate any text-based format (HTML, XML, CSV, LaTeX, etc.). A Jinja template doesn’t need to have a specific extension: .html, .xml, or any other extension is just fine.
>
>A template contains variables and/or expressions, which get replaced with values when a template is rendered; and tags, which control the logic of the template. The template syntax is heavily inspired by Django and Python.

Jinja is commonly encountered in Python-based projects like Ansible, where it's frequently used to template configuration files, rendered with dynamic inputs from the Ansible inventory and/or roles and playbooks.

It can also be useful to template and render files with information from environment variables using the Jinja CLI. This is a really useful pattern to build reusable CI/CD pipeline elements that behave in standard ways but source certain varying data points from the environment or an invokation of a pipeline at runtime.

e.g. you have Github Actions Environment Variables or Environment Secrets defined for pipeline runs. These Variables and Secrets are made available as shell variables in pipeline runs targetting a specific environment label/type (dev, test, prod). The pipeline can consume these common variables containing environment-specific values and render templates based on this for downstream processing.

## How-to
1. Install the Jinja CLI module from Pip, this example is from a Fedora system, adjust accordingly:
```
$ mkdir -p .venv/jinjacli/
$ python -m venv .venv/jinjacli/
$ . ~/.venv/jinjacli/bin/activate
$ python -m pip install --upgrade pip
$ pip install jinja-cli
```
> **Note**: There is an RPM-packaged Jinja CLI for Fedora but it doesn't parse environment variables as usefully.

2. Create an example template file:
```
$ cat > /tmp/credential.yml <<EOF
---
username: {{ APP_USER_NAME }}
password: {{ APP_SECRET_PASSWORD }}
EOF
```

3. Set some environment variables:
```
$ export APP_USER_NAME='sulaco'
$ export APP_SECRET_PASSWORD='x3nom0rph'
$ set | grep APP_
APP_SECRET_PASSWORD=x3nom0rph
APP_USER_NAME=sulaco
```

4. Test render the example template with the example environment variables:
```
$ jinja -X 'APP_*' /tmp/credential.yml 
---
username: sulaco
password: x3nom0rph
```
> **Note**: For a real pipeline with a credential we'd use a masked secret to ensure it remains unlogged.

## Further reading
- https://jinja.palletsprojects.com/en/3.1.x/
- https://jinja.palletsprojects.com/en/3.1.x/templates/
- https://pypi.org/project/jinja-cli/
- https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#about-environments
- https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-variables
- https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#environment-secrets