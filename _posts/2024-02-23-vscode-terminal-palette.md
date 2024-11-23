---
title: "Configure the VSCode terminal palette"
tags:
- microsoft
- vscode
- palette
---

## Overview
When working on Windows using a combination of WSL2 in the Windows Terminal, VSCode and either the WSL2 or Gitbash you may wish to have a relatively uniform colour palette 

## How-to
1. Open the command palette with `ctrl`-`shift`-`p`
2. Type "Preferences: Open User Settings (JSON)" and `ENTER`
3. Add the following entries to `settings.json` and _et violet!_:

```json
{
    "workbench.colorTheme": "Solarized Light",
    "workbench.colorCustomizations": {
        "terminal.background":"#2F1E2E",
        "terminal.foreground":"#A39E9B",
        "terminalCursor.background":"#A39E9B",
        "terminalCursor.foreground":"#A39E9B",
        "terminal.ansiBlack":"#2F1E2E",
        "terminal.ansiBlue":"#06B6EF",
        "terminal.ansiBrightBlack":"#776E71",
        "terminal.ansiBrightBlue":"#06B6EF",
        "terminal.ansiBrightCyan":"#5BC4BF",
        "terminal.ansiBrightGreen":"#48B685",
        "terminal.ansiBrightMagenta":"#815BA4",
        "terminal.ansiBrightRed":"#EF6155",
        "terminal.ansiBrightWhite":"#E7E9DB",
        "terminal.ansiBrightYellow":"#FEC418",
        "terminal.ansiCyan":"#5BC4BF",
        "terminal.ansiGreen":"#48B685",
        "terminal.ansiMagenta":"#815BA4",
        "terminal.ansiRed":"#EF6155",
        "terminal.ansiWhite":"#A39E9B",
        "terminal.ansiYellow":"#FEC418"
    }
}
```

## Further reading
- https://glitchbone.github.io/vscode-base16-term/#/paraiso
