import re

with open("tools/gen_lua_api.py", "r", encoding="utf-8") as f:
    text = f.read()

# Add a pre-pass to collect `const TYPE_NAME = "..."` logic
patch_1 = """    current_impl_type: Optional[str] = None
    current_widget_type: Optional[str] = None
    brace_depth = 0

    type_names = {}
    c_struct = None
    for l in lines:
        if "impl" in l and "LunaType for" in l:
            m = re.search(r'impl(?:<[^>]*>)?\s+(?:LunaType\s+for\s+)?(\w+)', l)
            if m: c_struct = m.group(1)
        if c_struct and 'const TYPE_NAME' in l:
            m2 = re.search(r'const\s+TYPE_NAME.*?=\s*"([^"]+)"', l)
            if m2:
                type_names[c_struct] = m2.group(1)
                c_struct = None"""

text = text.replace(
    '    current_impl_type: Optional[str] = None\n    brace_depth = 0',
    patch_1
)


# Add regex for `add_button_methods`
patch_2 = """    impl_re = re.compile(r'^\s*impl(?:<[^>]*>)?\s+(?:LuaUserData\s+for\s+)?(\w+)')
    add_method_re = re.compile(r'fn\s+add_(\w+)_methods\(')"""

text = text.replace(
    '    impl_re = re.compile(r\'^\\s*impl(?:<[^>]*>)?\\s+(?:LuaUserData\\s+for\\s+)?(\\w+)\')',
    patch_2
)


# Add catch for `add_button_methods`
patch_3 = """        impl_m = impl_re.match(stripped)
        if impl_m:
            current_impl_type = impl_m.group(1)

        add_m = add_method_re.search(stripped)
        if add_m:
            w_type = add_m.group(1).title()     # e.g. "button" -> "Button"
            current_widget_type = w_type"""

text = text.replace(
    '        impl_m = impl_re.match(stripped)\n        if impl_m:\n            current_impl_type = impl_m.group(1)',
    patch_3
)


# Clear current_widget_type when depth is 0
patch_4 = """        if brace_depth <= 0:
            current_impl_type = None
            current_widget_type = None
            brace_depth = 0"""

text = text.replace(
    '        if brace_depth <= 0:\n            current_impl_type = None\n            brace_depth = 0',
    patch_4
)


# Fix multiline set pattern
old_set_multi = """                    docstring = _collect_docstring_above(lines, i)
                    desc = docstring.split("\\n")[0] if docstring else ""
                    params, returns = _extract_params_returns(docstring)
                    inferred = _infer_signature(lines, i)
                    functions.append(LuaFunction(
                        module=module, name=func_name,
                        lua_name=f"luna.{module}.{func_name}",
                        owner_type="", description=desc,
                        full_doc=docstring, params=params,
                        returns=returns, line=i + 1,
                        file=rel_path, kind="function",
                        inferred_sig=inferred,
                        typed_params=_parse_tagged_params(docstring),
                        inferred_return=_parse_tagged_return(docstring),
                    ))"""

new_set_multi = """                    docstring = _collect_docstring_above(lines, i)
                    owner = current_widget_type if current_widget_type else ""
                    kind = "method" if owner else "function"
                    lua_name = f"{owner}:{func_name}" if owner else f"luna.{module}.{func_name}"

                    if not docstring and owner:
                        docstring = f"/// Returns a value for {func_name} (auto-generated)."

                    desc = docstring.split("\\n")[0] if docstring else ""
                    params, returns = _extract_params_returns(docstring)
                    inferred = _infer_signature(lines, i)

                    functions.append(LuaFunction(
                        module=module, name=func_name,
                        lua_name=lua_name,
                        owner_type=owner, description=desc,
                        full_doc=docstring, params=params,
                        returns=returns, line=i + 1,
                        file=rel_path, kind=kind,
                        inferred_sig=inferred,
                        typed_params=_parse_tagged_params(docstring),
                        inferred_return=_parse_tagged_return(docstring),
                    ))"""

text = text.replace(old_set_multi, new_set_multi)


# Fix singleline set pattern
old_set_inline = """            docstring = _collect_docstring_above(lines, i)
            desc = docstring.split("\\n")[0] if docstring else ""
            params, returns = _extract_params_returns(docstring)
            inferred = _infer_signature(lines, i)
            functions.append(LuaFunction(
                module=module, name=func_name,
                lua_name=f"luna.{module}.{func_name}",
                owner_type="", description=desc,
                full_doc=docstring, params=params,
                returns=returns, line=i + 1,
                file=rel_path, kind="function",
                inferred_sig=inferred,
                typed_params=_parse_tagged_params(docstring),
                inferred_return=_parse_tagged_return(docstring),
            ))"""

new_set_inline = """            docstring = _collect_docstring_above(lines, i)
            owner = current_widget_type if current_widget_type else ""
            kind = "method" if owner else "function"
            lua_name = f"{owner}:{func_name}" if owner else f"luna.{module}.{func_name}"

            if not docstring and owner:
                docstring = f"/// Returns a value for {func_name} (auto-generated)."

            desc = docstring.split("\\n")[0] if docstring else ""
            params, returns = _extract_params_returns(docstring)
            inferred = _infer_signature(lines, i)

            functions.append(LuaFunction(
                module=module, name=func_name,
                lua_name=lua_name,
                owner_type=owner, description=desc,
                full_doc=docstring, params=params,
                returns=returns, line=i + 1,
                file=rel_path, kind=kind,
                inferred_sig=inferred,
                typed_params=_parse_tagged_params(docstring),
                inferred_return=_parse_tagged_return(docstring),
            ))"""

text = text.replace(old_set_inline, new_set_inline)


# Fix display_owner for AiFlowField using the extracted type_names mapping
old_owner = """display_owner = owner.replace("Lua", "") if owner.startswith("Lua") else owner"""
new_owner = """display_owner = type_names.get(owner, owner.replace("Lua", "") if owner.startswith("Lua") else owner)"""

text = text.replace(old_owner, new_owner)

with open("tools/gen_lua_api.py", "w", encoding="utf-8") as f:
    f.write(text)
print("done! Replaced:", text != f.read() if False else "")
