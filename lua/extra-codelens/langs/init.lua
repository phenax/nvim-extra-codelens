
local M = {}

local typescript = function() return require('extra-codelens.langs.typescript') end

local langs = {
  typescript = typescript,
  javascript = typescript,
}

function M.get_lang(ft)
  local l = langs[ft]

  if l == nil then return nil end
  return l()
end

return M

