---
title: "Installing and Configuring Oh My Bash"
tags:
- linux
- bash
- terminal
- ohmybash
---

# Overview
I recently spent some brief time working on a project where they used [Oh My Bash](https://ohmybash.nntoan.com/) (OMB) as the default shell... prettifier?

It's effectively [Oh My Zsh](https://ohmyz.sh/) (OMZ) for ~~the elderly~~ Gen X-ers.

If you hated OMZ, you can hate OMB too. (I didn't like OMZ **at all** when I briefly used it, but that's a 'me' not an 'it' thing. I'm sure given time I'd have grown to love it, I just didn't have time... _at the time_.)

# Installing

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

# Configuring

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

# Customising
## Custom Aliases

### Motivation
Adding your own custom aliases to Oh My Bash (OMB) is relatively simple but requires a few things to be set Just So.

In this quick example, I wanted to be able to switch the OMB prompt on-the-fly relatively dynamically between fancy and simpler text-based themes.

[`powerline-light`](https://github.com/ohmybash/oh-my-bash/wiki/Themes#powerline-light) is my prefered default theme, but doesn't render well or read clearly when copied/pasted in to text or Markdown.

This makes it less than ideal when writing documentation or examples.

[`morris`](https://github.com/ohmybash/oh-my-bash/wiki/Themes#morris) is a much more traditional prompt which can largely be copied/pasted straight into documentation on-the-fly and remain clear and readable. (Most of the examples in this Gist are using `morris` for clarity.)

The obvious solution is a quick alias to switch themes on-the-fly, which in turn leads to OMB's [custom alias definition](https://github.com/ohmybash/oh-my-bash/blob/5ce9fadcde08c5751c6da008ae3a1d4053516caf/templates/bashrc.osh-template#L137-L140) (although it could just as easily be dropped into the end of `~/.bashrc`.

### Steps

1. Review the structure of `$OSH_CUSTOM`:
    ```
    [wmcdonald@fedora ~ ]$ tree $OSH_CUSTOM
    /home/wmcdonald/.oh-my-bash/custom
    ├── aliases
    │   └── example.aliases.sh
    ├── completions
    │   └── example.completion.sh
    ├── example.sh
    ├── plugins
    │   └── example
    │       └── example.plugin.sh
    └── themes
        └── example
            └── example.theme.sh
    ```

2. Create your custom alias file
    ```
    [wmcdonald@fedora ~ ]$ cat $OSH_CUSTOM/aliases/custom.aliases.sh
    alias simple='source ${OSH}/themes/morris/morris.theme.sh'
    alias fancy='source ${OSH}/themes/powerline-light/powerline-light.theme.sh'
    ```

3. Include your custom alias in the `alias()` array

    Edit the `~/.bashrc`:
    ```
    [wmcdonald@fedora ~ ]$ vim +'set nu' +99 ~/.bashrc
    ```

    Add `custom` to the `aliases()` array (line numbers shown for context):
    ```
    99:aliases=(
    100-  general
    101-  custom
    102-)
    ```

4. Test

    Run the `src` alias to re-source the default `~/.bashrc`:
    ```
    [wmcdonald@fedora ~ ]$ alias | grep src
    alias src='source ~/.bashrc'
    [wmcdonald@fedora ~ ]$ src
    ```

    Check the aliases exist:
    ```
    wmcdonald > ~ > alias | grep -E 'simple|fancy'
    alias fancy='source ${OSH}/themes/powerline-light/powerline-light.theme.sh'
    alias simple='source ${OSH}/themes/morris/morris.theme.sh'
    ```

    Call each alias in turn:
    ```
    wmcdonald > ~ > simple
    [wmcdonald@fedora ~ ]$ fancy
    wmcdonald > ~ >
    ```

    **Note:** the effect is far more obvious and pronounced when you see this in-the-shell. cf: [`powerline-light`](https://github.com/ohmybash/oh-my-bash/wiki/Themes#powerline-light) vs. [`morris`](https://github.com/ohmybash/oh-my-bash/wiki/Themes#morris)

5. ...

6. Profit!

## Custom Functions

### Motivation

In this instance, I wanted VSCode to automatically open a remote connection to a devcontainer from the command line. This is emminently achievable but does require some minor contortions converting sections of the path into hex.

It requires manipulation of some shell parameters so a simple alias won't suffice. However we can create a function and drop that into the OMB custom aliases to be sourced.

### Steps

1. Convert the shell script from Stackoverflow to a simple bash function.

    ```
    remotecode() {
        dir=`echo $(cd $1 && pwd)`;
        hex=`printf ${dir} | od -A n -t x1 | tr -d '[\n\t ]'`;
        base=`basename ${dir}`;
        code --folder-uri="vscode-remote://dev-container%2B${hex}/workspaces/${base}"
    }
    ```

2. Add to the custom aliases:

    ```
    [wmcdonald@fedora ~ ]$ cat .oh-my-bash/custom/aliases/custom.aliases.sh
    alias simple='source ${OSH}/themes/morris/morris.theme.sh'
    alias fancy='source ${OSH}/themes/powerline-light/powerline-light.theme.sh'

    remotecode() {
        dir=`echo $(cd $1 && pwd)`;
        hex=`printf ${dir} | od -A n -t x1 | tr -d '[\n\t ]'`;
        base=`basename ${dir}`;
        code --folder-uri="vscode-remote://dev-container%2B${hex}/workspaces/${base}"
    }
    ```

3. Once again, source the new config:

    ```
    [wmcdonald@fedora ~ ]$ src
    ```

4. Check the function has been sourced:

    ```
    [wmcdonald@fedora ~ ]$ type remotecode
    remotecode is a function
    remotecode ()
    {
        dir=`echo $(cd $1 && pwd)`;
        hex=`printf ${dir} | od -A n -t x1 | tr -d '[\n\t ]'`;
        base=`basename ${dir}`;
        code --folder-uri="vscode-remote://dev-container%2B${hex}/workspaces/${base}"
    }
    ```

5. Test the new function:

    ```
    [wmcdonald@fedora ~ ]$ remotecode ~/workspaces/pages/
    ```

    > **Note:** If you have the `devcontainer.json` under `.devcontainer/podman/devcontainer.json` you may need to symlink it to `.devcontainer/devcontainer.json`


## References
- [Oh My Bash](https://ohmybash.nntoan.com/)
- [Oh My Zsh](https://ohmyz.sh/)
- [https://stackoverflow.com/questions/60379221/how-to-attach-a-remote-container-using-vscode-command-line](https://stackoverflow.com/questions/60379221/how-to-attach-a-remote-container-using-vscode-command-line)
- [https://stackoverflow.com/questions/60861873/is-there-a-way-to-open-a-folder-in-a-container-from-the-vscode-command-line-usin](https://stackoverflow.com/questions/60861873/is-there-a-way-to-open-a-folder-in-a-container-from-the-vscode-command-line-usin)


## TODO
- Update https://github.com/ohmybash/oh-my-bash/wiki/Articles ?
- Split out the install / initial configure from the alias and function customisation, or structure more consistently/readably? 
