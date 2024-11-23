---
title: "Exporting/Importing Gnome Terminal Colour Profiles"
tags:
- linux
- gnome
- terminal
---

## Overview
I've spent a bit of time trying to figure out how to programatically switch themes in the Gnome terminal, so for example I could automatically colour-code a terminal window based on a local instance or container vs, different cloud providers.

It's easy enough to enumerate profiles but it's only really possible to change the default profile on-the-fly.

## Enumerate Terminal Profiles

1. We can list all extant terminal profiles by `dconf dump`-ing `/org/gnome/terminal/legacy/profiles`:

	```shell
	wmcdonald@fedora:~$ dconf dump /org/gnome/terminal/legacy/profiles:/
	[/]
	list=['b1dcc9dd-5262-4d8d-a863-c897e6d979b9', '7455b36d-c1a6-4be7-ba5e-c9337fe6b1a1', '7e895d7e-17b8-45f5-8dc2-0719fa1b90e7']

	[:7455b36d-c1a6-4be7-ba5e-c9337fe6b1a1]
	background-color='rgb(23,20,33)'
	foreground-color='rgb(208,207,204)'
	use-system-font=false
	use-theme-colors=false
	visible-name='dark'

	[:7e895d7e-17b8-45f5-8dc2-0719fa1b90e7]
	background-color='rgb(47,30,46)'
	bold-color-same-as-fg=true
	foreground-color='rgb(163,158,155)'
	use-system-font=false
	use-theme-colors=false
	visible-name='ubuntu'

	[:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]
	audible-bell=false
	background-color='rgb(253,246,227)'
	font='Monospace 12'
	foreground-color='rgb(51,64,69)'
	use-system-font=false
	use-theme-colors=false
	visible-name='light'
	```

2. We can list individual profiles

	```shell
	wmcdonald@fedora:~$ dconf dump /org/gnome/terminal/legacy/profiles:/:7e895d7e-17b8-45f5-8dc2-0719fa1b90e7/
	[/]
	background-color='rgb(47,30,46)'
	bold-color-same-as-fg=true
	foreground-color='rgb(163,158,155)'
	use-system-font=false
	use-theme-colors=false
	visible-name='ubuntu'
	```

	> **Note:** yes, yes, yes, we're using Ubuntu-ish terminal colours for Fedora


## References
- [Importing and Exporting GNOME Terminal Color Schemes](http://davidzchen.com/tech/2020/07/21/importing-and-exporting-gnome-terminal-color-schemes.html)
- [davidzchen.github.io](https://github.com/davidzchen/davidzchen.github.io)