
local M = {}

local typescript = function() return require('extra-codelens.langs.typescript') end

local langs = {
  typescript = typescript,
  javascript = typescript,
  lua = function() return require('extra-codelens.langs.lua') end,
}

function M.get_lang(ft)
  local l = langs[ft]

  if l == nil then return nil end
  return l()
end

return M

