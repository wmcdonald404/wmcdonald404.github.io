---
title: "Customising Oh My Bash"
tags:
- linux
- bash
- terminal
- ohmybash
---

# Overview
These are some of the post-install customisation steps I've taken to further tailor Oh My Bash to my local liking. 

# Customising Oh My Bash
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

## Custom Themes

### Motivation
As noted in [Custom Aliases](#custom-aliases), I like to have a fancy them for day-to-day Doing Stuff. Another simpler theme that's more readable in documentation where I'm capturing something for others.

[`morris`](https://github.com/ohmybash/oh-my-bash/wiki/Themes#morris) works well for this but does not include some niceties like Python Venv status. This is how we can add that...

This is essentially the verbatim example given in the upstream documentation: [Customization of Plugins and Themes](https://github.com/ohmybash/oh-my-bash?tab=readme-ov-file#customization-of--plugins-and-themes)

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

2. Copy our *to-be-fucked-with* theme over before customisation:

    ```
    [wmcdonald@fedora ~ ]$ cp -a ${OSH}/themes/morris/ ${OSH_CUSTOM}/themes/morris/
    ```

3. Update the theme with the additional elements we want.

    Here I'm selectively using elements of syntax from another theme that **IS** Python Venv aware but you can do as little or as much as you like to your customised copy of the theme.

    ```
    [wmcdonald@fedora ~ ]$ diff ${OSH}/themes/morris/morris.theme.sh ${OSH_CUSTOM}/themes/morris/morris.theme.sh
    19c19,22
    < 	PS1="${TITLEBAR}[\u@\h \W $(scm_prompt_info)]\$ "
    ---
    > 	local python_venv; _omb_prompt_get_python_venv
    >     	python_venv=$python_venv
    > 
    > 	PS1="${TITLEBAR}$python_venv[\u@\h \W $(scm_prompt_info)]\$ "
    ```
    
    Or, possibly more clearly, I've added lines 19,20 and ammended the `$python_venv` to `PS1` on line 22:

    ```
        18	function _omb_theme_PROMPT_COMMAND() {
    19		local python_venv; _omb_prompt_get_python_venv
    20	    	python_venv=$python_venv
    21	
    22		PS1="${TITLEBAR}$python_venv[\u@\h \W $(scm_prompt_info)]\$ "
    23	}
    ```

4. In my case, because I'm using these themes on-the-fly, I will **also** need to update the aliases defined in the next section on [Custom Function](#custom-functions) to reflect the new path. If I was simply defining my default theme this would not be required.

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
- [Customization of Plugins and Themes](https://github.com/ohmybash/oh-my-bash?tab=readme-ov-file#customization-of--plugins-and-themes)

## TODO
- Update https://github.com/ohmybash/oh-my-bash/wiki/Articles ?
- Split out the install / initial configure from the alias and function customisation, or structure more consistently/readably? 
