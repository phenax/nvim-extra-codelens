
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

return Lang

