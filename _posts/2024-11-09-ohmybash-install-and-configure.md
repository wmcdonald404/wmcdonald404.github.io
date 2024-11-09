---
title: "Installing and Configuring Oh My Bash"
tags:
- linux
- bash
- terminal
- ohmybash
---

## Overview
I recently spent some brief time working on a project where they used [Oh My Bash](https://ohmybash.nntoan.com/) (OMB) as the default shell... prettifier? 

It's effectively [Oh My Zsh](https://ohmyz.sh/) (OMZ) for ~~the elderly~~ Gen X-ers. 

If you hated OMZ, you can hate OMB too. (I didn't like OMZ **at all** when I briefly used it, but that's a 'me' not an 'it' thing. I'm sure given time I'd have grown to love it, I just didn't have time... _at the time_.)

## Installing

The [documentation](https://github.com/ohmybash/oh-my-bash?tab=readme-ov-file#basic-installation) covers both interactive and unattended installation, it's all pretty straightforward.

> **Note:** If you're working in a regulated environment, obviously do your due dilligence, don't just blithely run random stuff from the internet. Review [the install script](https://github.com/ohmybash/oh-my-bash/blob/master/tools/install.sh), maybe move it and a mirror of the upstream repo into an artefact repo that provides a degree of governance and surety. 

- Interactive:
```
$ bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

- [Unattended](https://github.com/ohmybash/oh-my-bash?tab=readme-ov-file#unattended-install):
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
```

## Configuring

The primary thing you'll want to configure is the prompt theme. This, in addition to your laptop stickers, will convey appropriate levels of leet status to your peers and random train people.

- Update `~/.bashrc` with your prefered theme:

```
[wmcdonald@fedora ~ ]$ vi +12 ~/.bashrc
```

```
 10 # Set name of the theme to load. Optionally, if you set this to "random"
 11 # it'll load a random theme each time that oh-my-bash is loaded.
 12 OSH_THEME="powerline-light"
```

(Line numbers shown for context.)

## Customising
### Custom Aliases
<script src="https://gist.github.com/wmcdonald404/b6dafc402ade36c4383ecf434694e5ca.js"></script>

## References
- [Oh My Bash](https://ohmybash.nntoan.com/)
- [Oh My Zsh](https://ohmyz.sh/)

## TODO
- Update https://github.com/ohmybash/oh-my-bash/wiki/Articles ? 