# nvim-extra-codelens [WIP]
Neovim plugin to show type information as virtual text for LSP's that don't support codelens

Currently supports the following languages:
- typescript
- lua


## Install

#### For [packer](https://github.com/wbthomason/packer.nvim) users -
```lua
  use 'phenax/nvim-extra-codelens'
```

#### Attach
```lua
require'extra-codelens'.on_attach(client, bufnr)

function on_attach(client, bufnr)
  -- ...
  require'extra-codelens'.on_attach(client, bufnr)
end

require'nvim_lsp'.tsserver.setup { on_attach = on_attach }
```


#### Run on a single buffer

```lua
-- to run on the current buffer
require'extra-codelens'.run_on_buffer()

-- to run in a different buffer
require'extra-codelens'.run_on_buffer(bufnr)
```

