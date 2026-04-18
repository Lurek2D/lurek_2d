"""One-shot fix for thread_api.rs docstrings.

Purpose: Repairs malformed `///` docstring blocks in `src/lua_api/thread_api.rs`
that were produced by an early auto-doc pass (e.g. blank summary, return tag
before description). Idempotent — safe to re-run.

Usage: python tools/fix/fix_thread_api.py

No CLI flags. Edits the file in place.
"""
import re
with open('src/lua_api/thread_api.rs', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('/// @return string\n        /// Type.\n        ///\n', '/// Returns the type of the object.\n        /// @return string\n')
content = content.replace('        /// @return boolean\n        /// Type of.\n        ///\n        /// @param name : string\n', '        /// Checks if the object is of the specified type.\n        /// @param name : string\n        /// @return boolean\n')
content = content.replace('        /// @return integer\n        /// Adds an item.\n        ///\n        /// @param value : any\n', '        /// Pushes a value to the channel.\n        /// @param value : any\n        /// @return integer\n')
content = content.replace('        /// @return string|number|boolean|table|nil\n        /// Removes an item.\n        ///\n', '        /// Retrieves and removes a value from the channel.\n        /// @return string|number|boolean|table|nil\n')
content = content.replace('        /// @return string|number|boolean|table|nil\n        /// Peek.\n        ///\n', '        /// Retrieves the value from the channel without removing it.\n        /// @return string|number|boolean|table|nil\n')
content = content.replace('        /// @return string|number|boolean|table|nil\n        /// Demand.\n        ///\n        /// @param timeout : number?\n', '        /// Blocks until a value is available or the timeout expires, then removes and returns it.\n        /// @param timeout : number?\n        /// @return string|number|boolean|table|nil\n')
content = content.replace('        /// @return integer\n        /// Returns the count.\n        ///\n', '        /// Returns the number of items in the channel.\n        /// @return integer\n')
content = content.replace('        /// @return nil\n        /// Clears the state.\n        ///\n', '        /// Clears all items from the channel.\n        /// @return nil\n')
content = content.replace('        /// @return nil\n        /// Supply.\n        ///\n        /// @param value : any\n', '        /// Blocks until the channel has space, then adds the value.\n        /// @param value : any\n        /// @return nil\n')

with open('src/lua_api/thread_api.rs', 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed thread_api.rs')
