local utils = require "extra-codelens.utils"
local langs = require "extra-codelens.langs"

local M = {}

local namespace = vim.api.nvim_create_namespace "extra-codelens"

--- Hello wordl
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function M.on_attach(client, bufnr)
  if client == nil then
    return
  end

  -- TODO: If supports textDocument/codelens, fallback to virtualtypes

  if not client.supports_method "textDocument/hover" then
    local err = string.format('nvim-extra-codelens: %s does not support "textDocument/hover" command', client.name)
    vim.api.nvim_command(string.format("echohl WarningMsg | echo '%s' | echohl None", err))
    return
  end

  M.run_on_buffer(bufnr)
end

function M.run_on_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  M._annotate_nodes(bufnr)
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWrite", "InsertLeave" }, {
    buffer = bufnr,
    callback = function()
      M._annotate_nodes(bufnr)
    end,
  })
end

function M._annotate_nodes(bufnr)
  vim.schedule(function()
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    local ft = vim.bo[bufnr].filetype
    local lang = langs.get_lang(ft)

    if lang == nil then
      print("Filetype " .. ft .. " not supported")
      return
    end

    local root = utils.get_root_node(bufnr, ft)
    for id, node in lang.declaration_query:iter_captures(root, bufnr, 0, -1) do
      if lang.declaration_query.captures[id] == "declaration_name" then
        M._show_codelens_for_node(bufnr, node, lang)
      end
    end
  end)
end

local extmarks = {}

function M._show_codelens_for_node(bufnr, node, lang)
  local row, col = node:range()

  local params = vim.lsp.util.make_position_params()
  params.position = { line = row, character = col }

  -- TODO: Use buf_request_all
  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
    if err ~= nil or result == nil then
      return
    end

    local position = string.format("%s%s", row, col)

    local id = extmarks[position]

    if id then
      vim.api.nvim_buf_del_extmark(bufnr, namespace, id)
    end

    extmarks[position] = vim.api.nvim_buf_set_extmark(bufnr, namespace, row, col, {
      virt_text = { { I(lang.extract_codeinfo(result)), "@comment" } },
    })
  end)
end

return M
