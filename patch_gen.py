import re

with open("tools/gen_lua_api.py", "r", encoding="utf-8") as f:
    content = f.read()

# 1. We need to collect TYPE_NAME. Let's do a fast pass:
# We parse the file beforehand to build a mapping from struct name to TYPE_NAME.
patch_1 = """    functions: List[LuaFunction] = []
    current_impl_type: Optional[str] = None
    current_widget_type: Optional[str] = None
    brace_depth = 0

    # Build type map for this file
    type_names = {}
    current_struct = None
    for line in lines:
        m = re.match(r'\\s*impl(?:<[^>]*>)?\\s+(?:LunaType\\s+for\\s+)?(\\w+)', line)
        if m: current_struct = m.group(1)
        if current_struct:
            m2 = re.search(r'const\\s+TYPE_NAME\\s*:\\s*&\\'static\\s*str\\s*=\\s*"([^"]+)"', line)
            if m2:
                type_names[current_struct] = m2.group(1)

    set_multiline_re = re.compile(r'(\\w+)\\.set\\(\\s*$')
    set_inline_re = re.compile(r'(\\w+)\\.set\\(\\s*"(\\w+)"\\s*,\\s*lua\\.create_function')
    name_next_re = re.compile(r'^\\s*"(\\w+)"\\s*,')
    method_re = re.compile(r'methods\\.add_method(?:_mut)?\\(\\s*"(\\w+)"')
    impl_re = re.compile(r'^\\s*impl(?:<[^>]*>)?\\s+(?:LuaUserData\\s+for\\s+)?(\\w+)')
    add_methods_re = re.compile(r'^\\s*fn\\s+add_(\\w+?)_methods\\(')"""

content = re.sub(
    r'    functions: List\[LuaFunction\] = \[\].*?impl_re = re\.compile\(r\'\^\\s\*impl\(\?:<\[\^>\]\*>\)\?\\s\+\(\?:LuaUserData\\s\+for\\s\+\)\?\(\\w\+\)\'\)',
    patch_1.replace('\\', '\\\\'),
    content,
    flags=re.DOTALL
)

print(len(content))
