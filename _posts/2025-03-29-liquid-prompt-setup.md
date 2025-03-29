---
title: "Customising Oh My Bash"
tags:
- linux
- bash
- terminal
- liquidprompt
---

* TOC
{:toc}

# Overview
I've been using [Oh My Bash](https://ohmybash.nntoan.com/) (OMB) for a few months after being introduced to it during a brief project last year. The themes, aliases and customisation are nice but I have found some slighly flaky TTY behaviour with some, if not all, themes. 

In the interim, I stumbled across [Liquid Prompt](https://liquidprompt.readthedocs.io/en/stable/) (LP), a similar project, but with a slightly narrower focus. 

OMB covers prompt themes, plugins, completions & aliases. LP focuses purely on the prompt, creating a dynamic prompt experience that reflects where you are and what you're doing (a little) more finely. 

# Example
For example, I have a few different AWS CLI profiles mapped to different accounts and/or roles, and a few simple aliases to toggle the currently configured profile. 

With LP enabled, the shell prompt dynamically reflects the current `AWS_PROFILE`, helping to indicate where I am and what I'm doing.

1. Check the current AWS_PROFILE environment variable value:
    ```
    [wmcdonald:~] $ echo $AWS_PROFILE
    ```
2. Review the simple AWS_PROFILE aliases set:
    ```
    [wmcdonald:~] $ alias | grep awsprofile
    alias awsprofile.home.administrator='export AWS_PROFILE=awsprofile.home.administrator'
    alias awsprofile.home.poweruser='export AWS_PROFILE=awsprofile.home.poweruser'
    ```
3. Switch to the poweruser role, note the prompt updates automatically:
    ```
    [wmcdonald:~] $ awsprofile.home.poweruser 
    [wmcdonald:~] (awsprofile.home.poweruser) $ echo $AWS_PROFILE
    ```
4. Check the value in `AWS_PROFILE`:
    ```
    [wmcdonald:~] (awsprofile.home.poweruser) $ echo $AWS_PROFILE
    awsprofile.home.poweruser
    ```
5. Switch to another AWS profile, again note the dynamic change: 
    ```
    [wmcdonald:~] (awsprofile.home.poweruser) $ awsprofile.home.administrator 
    [wmcdonald:~] (awsprofile.home.administrator) $ echo $AWS_PROFILE
    awsprofile.home.administrator
    ```

6. Finally, unset the profile and again, observe the dynamic change: 
    ```
    [wmcdonald:~] (awsprofile.home.administrator) $ unset AWS_PROFILE 
    [wmcdonald:~] $ echo $AWS_PROFILE

    [wmcdonald:~] $ 
    ```

# References
- [Liquid Prompt’s Documentation](https://liquidprompt.readthedocs.io/en/stable/)
- [Liquid Prompt's Github Repo](https://github.com/liquidprompt/liquidprompt)
- [Oh My Bash's Landing Page](https://ohmybash.nntoan.com/)
- [Oh My Bash's Github Repo](https://github.com/ohmybash/oh-my-bash)

# TODO
