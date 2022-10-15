
local utils = {}

function utils.get_node_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local node = vim.treesitter.get_node_at_pos(bufnr, line - 1, col)
  return node
end

function utils.get_root_node(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "typescript")
  return parser:parse()[1]:root()
end

return utils

