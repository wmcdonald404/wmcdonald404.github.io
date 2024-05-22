---
title: "Configure a VSCode Terminal Toggle"
date: 2024-02-23 12:10:00
tags:
- microsoft
- vscode
- terminal
---

## Overview
VSCode uses different keyboard shortcuts to start the integrated terminal and to switch focus from the editor pane to the terminal.

Configuring VSCode to use a single keyboard shortcut to both start a terminal if one isn't running/open and toggle focus between the editor and terminal is useful default behaviour for many workflows.

## How-to
1. Open the command palette with `ctrl`-`shift`-`p`
2. Type "Preferences: Open Keyboard Shortcuts (JSON)" and `ENTER`

    **Note**: This is a discrete entry, "Preferences: Open **Default** Keyboard Shortcuts (JSON)" is a different configuration element. 

3. Add the following entries to `keybindings.json`:

```
// Toggle between terminal and editor focus
{
    "key":     "ctrl+`",
    "command": "workbench.action.terminal.focus"
},
{
    "key":     "ctrl+`",
    "command": "workbench.action.focusActiveEditorGroup",
    "when":    "terminalFocus"
}
```

**Note**: some keyboards and/or regionalisation settings may require `ctrl+oem_8` in place of ``ctrl+` ``.

## Further reading
- https://stackoverflow.com/a/43012779
- https://stackoverflow.com/a/68730522
