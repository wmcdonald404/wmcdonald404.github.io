---
title: "Running Jekyll/Github Pages in a Devcontainer"
layout: default
date: 2024-10-17 15-30-00
tags:
- github
- github-pages
- jekyll
- devcontainer
- vscode
---

## Overview
I've written a few times in the past about setting up Github Pages. Behind the scenes Github Pages uses Jekyll as its templating mechanism, allowing people to write content in Markdown and then to render the markdown in to valid HTML themed with CSS.

On occasion, it's useful to be able to validate Jekyll-templated content locally, prior to publication/pushing to Github. For example the Markdown rendering in Jekyll is slightly different to the Markdown Preview in VSCode (VSCode keyboard shortcut: `CTRL`-`SHIFT`-`v`).

In order to serve Jekyll locally we can set up a Devcontainer using the existing [Devcontainer template definition](https://github.com/devcontainers/templates/tree/main/src/jekyll) and, with a few additional steps, serve content locally.

## Set up the Devcontainer

First, set up the Devcontainer. I'm  running Podman which requires a few additional elements out-of-the-box.

1. Create the Devcontainer folder:

	```
	wmcdonald@fedora:~/workspace/github-pages$ mkdir -p ~/workspace/github-pages/.devcontainer/podman
	```

2. Add the Devcontainer config:

	```
	{
        "name": "Jekyll",
        "image": "mcr.microsoft.com/devcontainers/jekyll:2-bookworm",
        "runArgs": [
                "--security-opt", "label=disable",
                "--userns=host",
                "--hostname=ansible-dev-container"
          ],
        "remoteUser": "root"
        // "onCreateCommand": ".devcontainer/bin/onCreateCommand.sh",
        // "updateContentCommand": ".devcontainer/bin/updateContentCommand.sh",
	}
	```

3. Open the Devcontainer:

	In VSCode, `CTRL`-`SHIFT`-`p`, then select `Dev Containers: Rebuild and Reopen in Container`

## Set up Jekyll

1. In the Devcontainer, start Jekyll by running `jekyll serve`:

	```
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

	If you only see a bare HTML index, we will need to add a valid `index.markdown`, either add the following contents to your repository:

	```
	root ➜ /workspaces/github-pages (main) $ cat index.markdown 
	---
	# Feel free to add content and custom Front Matter to this file.
	# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

	layout: home
	---
	```

	Or create a dummy Jekyll site and copy the `index.markdown`:

	```
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
	```

4. Restart the Jekyll server and retest your content.

5. As good practice, also append these additional items to `.gitignore`:

	```
	root ➜ /workspaces/github-pages (main) $ cat /tmp/jk/.gitignore 
	_site
	.sass-cache
	.jekyll-cache
	.jekyll-metadata
	vendor
	root ➜ /workspaces/github-pages (main) $ cat /tmp/jk/.gitignore >> /workspaces/github-pages/.gitignore
	```


> **Note:** You may need to add `layout: default` to the front-matter of each page for them to correctly render when served locally.

## References

- [VSCode, Docker, and Github Pages](https://www.allisonthackston.com/articles/vscode-docker-github-pages.html)
- [GitHub Pages in Dev Containers and Codespaces](https://blog.robsewell.com/blog/github-pages-in-dev-containers-and-codespaces/)
- []()
