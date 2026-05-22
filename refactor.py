import re

file_path = "src/lua_api/ai_api.rs"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Replace setter patterns
# let mut w = this.world.borrow_mut();
# if let Some(idx) = w.get_agent_index(&this.name) {
#     w.agents[idx].<expr>
# }
setter_pattern = re.compile(
    r'let mut w = this\.world\.borrow_mut\(\);\s*'
    r'if let Some\(idx\) = w\.get_agent_index\(&this\.name\) \{\s*'
    r'w\.agents\[idx\]\.(.*?);\s*'
    r'\}',
    re.MULTILINE
)
content = setter_pattern.sub(
    r'if let Some(agent) = this.world.borrow_mut().agent_mut(&this.name) {\n                agent.\1;\n            }',
    content
)

# Replace getter patterns
# let w = this.world.borrow();
# if let Some(idx) = w.get_agent_index(&this.name) {
#     Ok(w.agents[idx].<expr>)
# } else {
#     Ok(<default>)
# }
getter_pattern = re.compile(
    r'let w = this\.world\.borrow\(\);\s*'
    r'if let Some\(idx\) = w\.get_agent_index\(&this\.name\) \{\s*'
    r'Ok\(w\.agents\[idx\]\.(.*?)\)\s*'
    r'\} else \{\s*'
    r'Ok\((.*?)\)\s*'
    r'\}',
    re.MULTILINE
)
content = getter_pattern.sub(
    r'if let Some(agent) = this.world.borrow().agent(&this.name) {\n                Ok(agent.\1)\n            } else {\n                Ok(\2)\n            }',
    content
)

# Replace blackboard getter
# match w.get_agent_index(&name) {
#     Some(idx) => LuaAIBlackboard {
#         inner: Rc::new(RefCell::new(w.agents[idx].blackboard.clone())),
#     },
#     None => continue,
# }
content = content.replace(
    '''match w.get_agent_index(&name) {
                        Some(idx) => LuaAIBlackboard {
                            inner: Rc::new(RefCell::new(w.agents[idx].blackboard.clone())),
                        },
                        None => continue,
                    }''',
    '''match w.agent(&name) {
                        Some(agent) => LuaAIBlackboard {
                            inner: Rc::new(RefCell::new(agent.blackboard.clone())),
                        },
                        None => continue,
                    }'''
)

# Replace other blackboard getter
content = content.replace(
    '''let w = this.world.borrow();
            if let Some(idx) = w.get_agent_index(&this.name) {
                Ok(LuaAIBlackboard {
                    inner: Rc::new(RefCell::new(w.agents[idx].blackboard.clone())),
                })
            } else {
                Err(LuaError::RuntimeError(format!(
                    "agent '{}' not found",
                    this.name
                )))
            }''',
    '''if let Some(agent) = this.world.borrow().agent(&this.name) {
                Ok(LuaAIBlackboard {
                    inner: Rc::new(RefCell::new(agent.blackboard.clone())),
                })
            } else {
                Err(LuaError::RuntimeError(format!(
                    "agent '{}' not found",
                    this.name
                )))
            }'''
)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)
print("Replaced successfully")
