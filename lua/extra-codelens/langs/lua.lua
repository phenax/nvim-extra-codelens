local Lang = {}

Lang.declaration_query = vim.treesitter.parse_query("lua", [[
  (variable_declaration (assignment_statement (variable_list name:(identifier) @declaration_name)))
  (function_declaration name:(dot_index_expression field:(identifier) @declaration_name))
]])

function Lang.extract_codeinfo(result)
  local contents = ""
  if result.contents and type(result.contents.value) == "string" then
    contents = result.contents.value
  end

  local type_info = ""
  for match in contents:gmatch('```lua(.*)```') do
    type_info = type_info .. match
  end

  type_info = type_info:gsub("%s*local%s*[A-Za-z0-9_]+:%s*", "")

  return ": " .. type_info:gsub('%s+', ' ')
end

return Lang

