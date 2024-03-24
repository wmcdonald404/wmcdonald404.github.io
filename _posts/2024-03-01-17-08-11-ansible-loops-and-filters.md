---
title: "Ansible Loops & Filters"
date: 2024-03-01 17-08-11
tags:
- redhat
- ansible
- loops
- filters
---

## Overview
Prompted by a user question on the [`ansible-project`](https://groups.google.com/g/ansible-project?pli=1) Google Group mailing list, I wanted to document the behaviours of each of the current types of loops and common filters with example input data and outputs.

## How-to
See the [ansible-loops](https://github.com/wmcdonald404/ansible-loops?tab=readme-ov-file#ansible-loops) repository for more details.


## Topics
{% for tag in page.tags %}
    {{ tag }}
{% endfor %}