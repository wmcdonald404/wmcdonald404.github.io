---
title: "Running Jekyll/Github Pages in a Devcontainer"
tags:
- github
- github-pages
- jekyll
- devcontainer
- vscode
- podman
---

* TOC
{:toc}

# Overview
I've written a [few times](https://wmcdonald404.co.uk/2024/01/02/github-pages-simple-blog.html) in [the past](https://wmcdonald404.co.uk/2024/03/25/github-page-creation-with-jinja.html) about setting up Github Pages. 

Behind the scenes Github Pages uses Jekyll as its templating mechanism, allowing people to write content in Markdown and then to render the markdown in to valid HTML themed with CSS.

On occasion, it's useful to be able to validate Jekyll-templated content locally, prior to publication/pushing to Github. For example the Markdown rendering in Jekyll is slightly different to the Markdown Preview in VSCode (VSCode keyboard shortcut: `CTRL`-`SHIFT`-`v`).

In order to serve Jekyll locally we can set up a [Devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) using the existing [Devcontainer template definition](https://github.com/devcontainers/templates/tree/main/src/jekyll) and, with a few additional steps, serve content locally.

# Set up the Devcontainer

First, set up the Devcontainer. I'm  running Podman which requires a few additional elements out-of-the-box.

1. Create the Devcontainer folder:

	```shell
	wmcdonald@fedora:~/workspace/github-pages$ mkdir -p ~/workspace/github-pages/.devcontainer/podman
	```

2. Add the Devcontainer config in `devcontainer.json`:

	```json
	wmcdonald@fedora:~/workspace/github-pages$ cat ~/workspace/github-pages/.devcontainer/podman/devcontainer.json
	{
        "name": "Jekyll",
        "image": "mcr.microsoft.com/devcontainers/jekyll:2-bookworm",
        "runArgs": [
                "--security-opt", "label=disable",
                "--userns=host",
                "--hostname=jekyll-dev-container"
          ],
        "remoteUser": "root"
        // "onCreateCommand": ".devcontainer/bin/onCreateCommand.sh",
        // "updateContentCommand": ".devcontainer/bin/updateContentCommand.sh",
	}
	```

	> **Note #1:** The `runArgs` used here are the minimum required to run the Devcontainer on Podman. Docker may run with fewer explicit options.

	> **Note #2:** We're using Podman so we can drop a Podman-specific devcontainer configuration into `.devcontainer/podman/devcontainer.json`, we can also have a Docker-specific devcontainer configuration in `.devcontainer/docker/devcontainer.json`. The plugin should in theory chose the correct config for the runtime in use.

3. Open the Devcontainer:

	In VSCode, `CTRL`-`SHIFT`-`p`, then select `Dev Containers: Rebuild and Reopen in Container`

# Set up Jekyll

1. In the Devcontainer, start Jekyll by running `jekyll serve`:

	```shell
	root ➜ /workspaces/github-pages (main) $ jekyll serve
	Configuration file: /workspaces/github-pages/_config.yml
				Source: /workspaces/github-pages
		Destination: /workspaces/github-pages/_site
	Incremental build: disabled. Enable with --incremental
		Generating... 
		Jekyll Feed: Generating feed for posts
	... <<snip>> ...
						done in 0.295 seconds.
	Auto-regeneration: enabled for '/workspaces/github-pages'
		Server address: http://127.0.0.1:4000
	Server running... press ctrl-c to stop.
	```

2. Test Local Content Serving

	Open a browser and navigate to [http://127.0.0.1:4000](http://127.0.0.1:4000). Depending on the state of your Jekyll site content, you may only see a bare HTML index, if this is the case see the following step.

3. Fix the Wrinkle in Rendering

	If you only see a bare HTML index, we will need to add a `layout` to the `index.md`.
	
	```shell
	root ➜ /workspaces/github-pages (main) $ cat index.md
	---
	# Feel free to add content and custom Front Matter to this file.
	# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

	layout: home
	---
	```

4. **Optionally:** Restart the Jekyll server and retest your content. 

	Jekyll will hot-reload changes by default, although this behaviour can be controlled through config. 

5. As good practice, also append these additional items to `.gitignore`:

	```shell
	root ➜ /workspaces/github-pages (main) $ cat /tmp/jk/.gitignore 
	_site
	.sass-cache
	.jekyll-cache
	.jekyll-metadata
	vendor
	root ➜ /workspaces/github-pages (main) $ cat /tmp/jk/.gitignore >> /workspaces/github-pages/.gitignore
	```

6. If you still have CSS rendering issues with individual posts, you can include the following in `_config.yml`:

	```yaml
	defaults:
	-
		scope:
		type: posts
		path: _posts
		values:
		isPost: true
		layout: post
	```

# Notes

## `devcontainer-info`

You can see more about the devcontainer you're using by running `devcontainer-info`:

```shell
07:50:29 root@jekyll-dev-container wmcdpages ±|main|→ devcontainer-info 

Development container image information

- Image version: 2.1.9
- Definition ID: jekyll
- Variant: 3.3-bookworm
- Source code repository: https://github.com/devcontainers/images
- Source code release/branch: v0.4.8
- Timestamp: Wed, 16 Oct 2024 18:48:12 GMT

More info: https://github.com/devcontainers/images/tree/main/src/jekyll/history/2.1.9.md
```

## Devcontainer Build Details

You can see more about how the devcontainer was built reviewing:
- [the history markdown](https://github.com/devcontainers/images/blob/main/src/jekyll/history/2.1.8.md?plain=1)
- [the Dockerfile](https://github.com/devcontainers/images/blob/main/src/jekyll/.devcontainer/Dockerfile)
- [the `devcontainer.json`](https://github.com/devcontainers/images/blob/main/src/jekyll/.devcontainer/devcontainer.json)

We can see the Dockerfile COPY in `/usr/local/post-create.sh` and that the `devcontainer.json` sets `"postCreateCommand": "sh /usr/local/post-create.sh"`. 

As a result, [`post-create.sh`](https://github.com/devcontainers/images/blob/main/src/jekyll/.devcontainer/post-create.sh) runs on devcontainer startup to `bundle install` if a `Gemfile` is present.

## Scratch Jekyll site

If you need a quick Jekyll dummy site to expirment, test theming or generally fuck around and find out, you can create an entirely new throwaway site and serve it as follows:


```shell
root ➜ /workspaces/github-pages (main) $ mkdir /tmp/jk
root ➜ /workspaces/github-pages (main) $ jekyll new /tmp/jk/
Running bundle install in /tmp/jk... 
Bundler: Fetching gem metadata from https://rubygems.org/............
Bundler: Resolving dependencies...
Bundler: Fetching rake 13.2.1
Bundler: Installing rake 13.2.1
Bundler: Fetching bigdecimal 3.1.8
Bundler: Installing bigdecimal 3.1.8 with native extensions
Bundler: Fetching google-protobuf 4.28.2 (x86_64-linux)
Bundler: Installing google-protobuf 4.28.2 (x86_64-linux)
Bundler: Fetching sass-embedded 1.80.1 (x86_64-linux-gnu)
Bundler: Installing sass-embedded 1.80.1 (x86_64-linux-gnu)
Bundler: Fetching minima 2.5.2
Bundler: Installing minima 2.5.2
Bundler: Bundle complete! 7 Gemfile dependencies, 35 gems now installed.
Bundler: Use `bundle info [gemname]` to see where a bundled gem is installed.
New jekyll site installed in /tmp/jk. 
root ➜ /workspaces/github-pages (main) $ cd /tmp/jk/
root ➜ /workspaces/github-pages (main) $ jekyll serve
```

# References

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [VSCode, Docker, and Github Pages](https://www.allisonthackston.com/articles/vscode-docker-github-pages.html)
- [GitHub Pages in Dev Containers and Codespaces](https://blog.robsewell.com/blog/github-pages-in-dev-containers-and-codespaces/)
- [images / src / jekyll / .devcontainer/](https://github.com/devcontainers/images/tree/main/src/jekyll/.devcontainer)