# Markdown Numbered Header

Neovim plugin for automatically numbering markdown headers.

## Features

- Customizable starting level
- Automatic renumbering on save
- Support per file control using comments

## Installation

Using lazy.nvim:
```lua
return {
  "fireond/number-markdown.nvim",
  opts = {}
}
```

## Configuration options
```lua
{
  start_level = 2,    -- Start numbering from h2 headers
  auto_update = true  -- Auto-update on save, can be boolean or function
}
```

## Usage

### Functions

```lua
require("number-markdown").number_headers()
require("number-markdown").clear_numbers()
require("number-markdown").toggle_auto_update()
require("number-markdown").get_auto_update_status()
```

### Commands
 
```
:MDNumberHeaders
:MDClearHeaders
:MDToggleAutoUpdate
```

### Per file control

Search lines with syntax `set property = value`. Examples:

- set `start_level`:
```md
<!-- set start_level=1 -->
# 1 H1
## 1.1 H2
## 1.2 H2
```

- set `counter`:
```md
<!-- set start_level=1 -->
# 1 H1
## 1.1 H2
<!-- set counter=5 -->
## 1.5 H2
```
