---
title: "Streamline Github Page Creation with Jinja"
tags:
- github
- jinja
---

## Overview
Building on the initial steps to create [Create a simple GitHub Pages blog post](https://wmcdonald404.github.io/github-pages/2024/01/02/github-pages-simple-blog.html) and [Using Jinja with shell variables from the CLI](https://wmcdonald404.github.io/github-pages/2024/03/23/jinja-cli-environment-variables.html) we can combine Jinja with a template and some environment variables to streamline initial page creation.

## Background
The initial set up of each page and its frontmatter for each post was simple but fiddly as first documented. We had already simplified the process with environment variables, now we attempt to streamline the process further using Jinja, and a template. The simplification over the previous [HEREDOC](https://tldp.org/LDP/abs/html/here-docs.html) is nominal but should ultimately be easier. 

Now let's walk through the slightly improved process.

## How-to
1. Set some common variables to reuse in subsequent steps.

    Set the current date & time, and the subject of the blog post:
    ```shell
    export BLOGDATE=$(date -I)
    export BLOGTITLE='Updated Github pages post'
    export BLOGFILE=blog-title.md
    echo $BLOGDATE $BLOGTIME $BLOGTITLE $BLOGFILE
    ```
    Or, in a slightly more compressed form:
    ```shell
    export BLOGDATE=$(date -I)
    export BLOGTITLE='Updated Github pages post'
    export BLOGFILE=blog-title.md
    echo $BLOGDATE $BLOGTIME $BLOGTITLE $BLOGFILE
    ```

2. Activate the Python virtual environment (venv) containing the Jinja CLI:
    ```shell
    $ . ~/.venv/jinjacli/bin/activate
    ```

3. Populate [the template](https://github.com/wmcdonald404/github-pages/blob/main/template.yml) using Jinja:
    ```shell
    $ jinja -X 'BLOG*' ~/repos/github-pages/_templates/post_template.md > ~/repos/github-pages/_posts/${BLOGDATE}-${BLOGTIME//:/-}-${BLOGFILE}
    ```
    **Note**: the `{BLOGTIME//:/-}` construct uses [bash substring replacement](https://tldp.org/LDP/abs/html/string-manipulation.html) to switch from colons (required for the frontmatter in the post's markdown) to a hyphen, for the file name.

## Summary
We now have a simpler process to quickly boilerplate a new blog article with its frontmatter. 

## Further reading
- [Jinja Template Designer Documentation](https://jinja.palletsprojects.com/en/3.1.x/templates/)
