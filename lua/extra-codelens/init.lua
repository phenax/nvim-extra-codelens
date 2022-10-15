local M = {}

-- local function get_node()
--   local bufnr = vim.api.nvim_get_current_buf()
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   local node = vim.treesitter.get_node_at_pos(bufnr, line - 1, col)
--   return node
-- end

local function extract_codeinfo(resp)
  local contents = vim.tbl_map(function(r)
    return vim.tbl_map(function(v) return v.value end,
      vim.tbl_filter(function(v) return type(v) == "table" end,
        r.result.contents
      )
    )
  end, resp)

  -- TODO: Handle when contents is just single value
  -- TODO: Handle string content

  return table.concat(vim.tbl_flatten(contents), ', ')
end

local namespace = vim.api.nvim_create_namespace("extra-codelens")

function M.setup()
  local bufnr = vim.api.nvim_get_current_buf()

  local declaration_query = vim.treesitter.parse_query("typescript", [[
    (function_declaration name:(identifier) @declaration_name)
    (variable_declarator name:(identifier) @declaration_name)
    (type_alias_declaration name:(type_identifier) @declaration_name)
  ]])

  vim.defer_fn(function()
    local parser = vim.treesitter.get_parser(bufnr, "typescript")
    local root = parser:parse()[1]:root()
  
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

    for id, node in declaration_query:iter_captures(root, bufnr, 0, -1) do
      local tag = declaration_query.captures[id]
      if tag == "declaration_name" then
        M.show_codelens_for_node(bufnr, node)
      end
    end
  end, 0)
end

function M.show_codelens_for_node(bufnr, node)
  local row, col = node:range()

  local params = vim.lsp.util.make_position_params()
  params.position = { line = row, character = col }

  local response = vim.lsp.buf_request_sync(bufnr, "textDocument/hover", params)

  local codeinfo = extract_codeinfo(response)

  vim.api.nvim_buf_set_extmark(bufnr, namespace, row, col, {
    virt_text = { { ":: " .. codeinfo, "DiagnosticHint" } },
  })
end

return M
