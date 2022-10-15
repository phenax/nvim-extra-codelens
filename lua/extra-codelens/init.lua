local M = {}

local function get_node()
  local bufnr = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local node = vim.treesitter.get_node_at_pos(bufnr, line - 1, col)
  return node
end

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
  local node = get_node()

  M.show_codelens_for_node(bufnr, node)
end

function M.show_codelens_for_node(bufnr, node)
  local row, col = node:range()

  local params = vim.lsp.util.make_position_params()
  params.position = { line = row, character = col }

  local response = vim.lsp.buf_request_sync(bufnr, "textDocument/hover", params)

  local codeinfo = extract_codeinfo(response)

  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
  vim.api.nvim_buf_set_extmark(bufnr, namespace, row, col, {
    virt_text = { { ":: " .. codeinfo, "DiagnosticHint" } },
  })
end


-- local x =  {
--     result = {
--       contents = {
--         {
--           language = "typescript",
--           value = "const debounceAsync: <T, Args extends any[]>(funcToExec: (...args: Args) => Promise<T>, wait: number) => (...args: Args) => Promise<T>"
--         },
--         "debounce for async function.\n\nThe debounced function returns a Promise that resolves only upo n the next\ninvocation of the `funcToExec` argument.\n\n*@param* `funcToExec` — async function to exec  \n\n*@param* `wait` — waiting time, in ms"
--       },
--       range = {
--         ["end"] = {
--           character = 26,
--           line = 9
--         },
--         start = {
--           character = 13,
--           line = 9
--         }
--       }
--     }
--   }
-- }
--
return M
