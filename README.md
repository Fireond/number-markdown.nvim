# Markdown Numbered Header

Neovim plugin for automatically numbering markdown headers.

## Features

- Customizable starting level
- Automatic renumbering on save

## Installation

Using lazy.nvim:
```lua
return {
  "fireond/number-markdown.nvim"
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

```lua
require("number-markdown").renumber_headers()
```
