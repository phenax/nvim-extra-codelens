local Lang = {}

Lang.declaration_query = vim.treesitter.parse_query("typescript", [[
  (program (function_declaration name:(identifier) @declaration_name))
  (program (lexical_declaration (variable_declarator name:(identifier) @declaration_name)))
  (program (type_alias_declaration name:(type_identifier) @declaration_name))

  (export_statement declaration:(function_declaration name:(identifier) @declaration_name))
  (export_statement declaration:(lexical_declaration (variable_declarator name:(identifier) @declaration_name)))
  (export_statement declaration:(type_alias_declaration name:(type_identifier) @declaration_name))
]])

function Lang.extract_codeinfo(result)
  local contents = ""
  for _,v in pairs(result.contents) do
    if type(v) == "table" then
      if contents == "" then
        contents = v.value
      else
        contents = contents .. ', ' .. v.value
      end
    end
  end

  -- Trim extra whitespaces
  contents = string.gsub(contents, '%s+', ' ')

  -- Transform type
  contents = string.gsub(contents, '^%s*const [A-Za-z0-9$_-]+:%s*', '')
  contents = string.gsub(contents, '^%s*function %w+%s*', 'function ')

  return ": " .. contents
end

return Lang

