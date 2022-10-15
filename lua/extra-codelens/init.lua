local utils = require('extra-codelens.utils')

local M = {}

local function extract_codeinfo(result)
  -- TODO: Try for instead
  local contents = vim.tbl_map(function(v) return v.value end,
    vim.tbl_filter(function(v) return type(v) == "table" end,
      result.contents
    )
  )

  -- TODO: Handle when contents is just single value
  -- TODO: Handle string content

  return table.concat(vim.tbl_flatten(contents), ', ')
end

local namespace = vim.api.nvim_create_namespace("extra-codelens")

local declaration_query = vim.treesitter.parse_query("typescript", [[
  (function_declaration name:(identifier) @declaration_name)
  (variable_declarator name:(identifier) @declaration_name)
  (type_alias_declaration name:(type_identifier) @declaration_name)
]])

function M.on_attach(client, _bufnr)
  -- if client == nil then return end
  -- if not client.supports_method('textDocument/hover') then
  --   local err = string.format(
  --     "nvim-extra-codelens: %s does not support \"textDocument/hover\" command",
  --     client.name)
  --   vim.api.nvim_command(string.format("echohl WarningMsg | echo '%s' | echohl None", err))
  --   return
  -- end

  local bufnr = vim.api.nvim_get_current_buf()

  M.annotate_nodes(bufnr)
  vim.api.nvim_create_autocmd({"BufEnter", "BufWrite", "InsertLeave"}, {
    buffer = bufnr,
    callback = function() M.annotate_nodes(bufnr) end,
  })
end

function M.annotate_nodes(bufnr)
  vim.schedule(function()
    local root = utils.get_root_node(bufnr)

    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    for id, node in declaration_query:iter_captures(root, bufnr, 0, -1) do
      if declaration_query.captures[id] == "declaration_name" then
        M.show_codelens_for_node(bufnr, node)
      end
    end
  end)
end

function M.show_codelens_for_node(bufnr, node)
  local row, col = node:range()

  local params = vim.lsp.util.make_position_params()
  params.position = { line = row, character = col }

  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
    if err ~= nil then return end

    local codeinfo = extract_codeinfo(result)

    vim.api.nvim_buf_set_extmark(bufnr, namespace, row, col, {
      virt_text = { { ":: " .. codeinfo, "DiagnosticHint" } },
    })
  end)
end

return M
