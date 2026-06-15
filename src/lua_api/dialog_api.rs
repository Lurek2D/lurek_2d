//! File: src/lua_api/dialog_api.rs
//! Module API documentation
//!
//! TODO: add doc note 1
//! TODO: add doc note 2
//! TODO: add doc note 3

use crate::dialog::{
    DialogSequencer, DialogueAI, DialogueState, SequencerNode, Speaker, SpeakerRegistry,
};
use crate::runtime::SharedState;
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Lua handle for topic and branch selection driven by dialogue AI state.
#[derive(Clone)]
pub(crate) struct LuaDialogueAI {
    /// Shared dialogue selector containing topics, branches, and decision context.
    pub inner: Rc<RefCell<DialogueAI>>,
}

/// Lua handle for dialog conversation state tracking.
#[derive(Clone)]
pub(crate) struct LuaDialogueState {
    /// Shared dialogue state with visited nodes and variables.
    pub inner: Rc<RefCell<DialogueState>>,
}

/// Lua userdata handle for managing a named speaker registry.
#[derive(Clone)]
pub(crate) struct LuaSpeakerRegistry {
    /// Shared speaker registry exposed by the lurek engine.
    pub inner: Rc<RefCell<SpeakerRegistry>>,
}

/// Lua handle for a dialog sequencer with typewriter-reveal playback.
#[derive(Clone)]
pub(crate) struct LuaDialogSequencer {
    /// Sequencer managing node playback, choices, and typewriter effect.
    pub inner: Rc<RefCell<DialogSequencer>>,
}

impl LuaUserData for LuaDialogueAI {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- setFSMState --
        /// Sets the finite-state-machine state used as dialogue selection context.
        /// @param | state | string? | Current FSM state name, or nil to clear the FSM context.
        methods.add_method("setFSMState", |_, this, state: Option<String>| {
            this.inner.borrow_mut().set_fsm_state(state);
            Ok(())
        });
        // -- setBTStatus --
        /// Sets the behavior-tree status used as dialogue selection context.
        /// @param | status | string? | Current behavior tree status, or nil to clear the status context.
        methods.add_method("setBTStatus", |_, this, status: Option<String>| {
            this.inner.borrow_mut().set_bt_status(status);
            Ok(())
        });
        // -- setUtilityScore --
        /// Stores a utility score used by topics and branches that reference the given key.
        /// @param | key | string | Utility score key.
        /// @param | score | number | Utility score value used during weighted selection.
        methods.add_method("setUtilityScore", |_, this, (key, score): (String, f32)| {
            this.inner.borrow_mut().set_utility_score(key, score);
            Ok(())
        });
        // -- clearUtilityScores --
        /// Removes every stored utility score from this dialogue selector.
        methods.add_method("clearUtilityScores", |_, this, ()| {
            this.inner.borrow_mut().clear_utility_scores();
            Ok(())
        });
        // -- addTopic --
        /// Adds a selectable dialogue topic with optional context filters.
        /// @param | id | string | Unique topic identifier.
        /// @param | weight | number? | Base selection weight; defaults to 1.0.
        /// @param | fsm_state | string? | Optional FSM state required for this topic.
        /// @param | bt_status | string? | Optional behavior tree status required for this topic.
        /// @param | utility_key | string? | Optional utility score key multiplied into selection.
        methods.add_method(
            "addTopic",
            |_,
             this,
             (id, weight, fsm_state, bt_status, utility_key): (
                String,
                Option<f32>,
                Option<String>,
                Option<String>,
                Option<String>,
            )| {
                this.inner.borrow_mut().add_topic(
                    id,
                    weight.unwrap_or(1.0),
                    fsm_state,
                    bt_status,
                    utility_key,
                );
                Ok(())
            },
        );
        // -- addBranch --
        /// Adds a selectable branch under an existing dialogue topic.
        /// @param | topic_id | string | Topic identifier that receives the branch.
        /// @param | branch_id | string | Unique branch identifier within the topic.
        /// @param | weight | number? | Base branch weight; defaults to 1.0.
        /// @param | fsm_state | string? | Optional FSM state required for this branch.
        /// @param | bt_status | string? | Optional behavior tree status required for this branch.
        /// @param | utility_key | string? | Optional utility score key multiplied into selection.
        /// @return | boolean | True when the branch was added to an existing topic.
        methods.add_method(
            "addBranch",
            |_,
             this,
             (topic_id, branch_id, weight, fsm_state, bt_status, utility_key): (
                String,
                String,
                Option<f32>,
                Option<String>,
                Option<String>,
                Option<String>,
            )| {
                Ok(this.inner.borrow_mut().add_branch(
                    &topic_id,
                    branch_id,
                    weight.unwrap_or(1.0),
                    fsm_state,
                    bt_status,
                    utility_key,
                ))
            },
        );
        // -- selectTopic --
        /// Selects the best currently valid topic using weights and context filters.
        /// @return | string | Selected topic identifier, or nil when no topic is available.
        methods.add_method("selectTopic", |_, this, ()| {
            Ok(this.inner.borrow().select_topic())
        });
        // -- selectBranch --
        /// Selects the best currently valid branch for the given topic.
        /// @param | topic_id | string | Topic identifier whose branches should be considered.
        /// @return | string | Selected branch identifier, or nil when no branch is available.
        methods.add_method("selectBranch", |_, this, topic_id: String| {
            Ok(this.inner.borrow().select_branch(&topic_id))
        });
        // -- getTopicCount --
        /// Returns the number of topics registered in this dialogue selector.
        /// @return | integer | Current topic count.
        methods.add_method("getTopicCount", |_, this, ()| {
            Ok(this.inner.borrow().topic_count())
        });
        // -- type --
        /// Returns the Lua-visible type name for this dialogue AI handle.
        /// @return | string | The string `LDialogueAI`.
        methods.add_method("type", |_, _, ()| Ok("LDialogueAI"));
        // -- typeOf --
        /// Returns whether this dialogue AI handle matches a supported type name.
        /// @param | name | string | Type name to compare against `DialogueAI` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDialogueAI" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaDialogueState {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- start --
        /// Starts a conversation at the given node.
        /// @param | node_id | string | Starting node identifier.
        methods.add_method("start", |_, this, node_id: String| {
            this.inner.borrow_mut().start(node_id);
            Ok(())
        });
        // -- advance --
        /// Advances to a new node in the conversation.
        /// @param | node_id | string | Node identifier to advance to.
        methods.add_method("advance", |_, this, node_id: String| {
            this.inner.borrow_mut().advance(node_id);
            Ok(())
        });
        // -- end_ --
        /// End the active conversation and release its state data.
        methods.add_method("end_", |_, this, ()| {
            this.inner.borrow_mut().end();
            Ok(())
        });
        // -- current --
        /// Returns the ID of the currently active dialogue node or nil.
        /// @return | string | Current node identifier, or nil when no node is active.
        methods.add_method("current", |_, this, ()| {
            Ok(this.inner.borrow().current().map(|s| s.to_string()))
        });
        // -- hasVisited --
        /// Check whether a given conversation node has been visited.
        /// @param | node_id | string | Node identifier to check.
        /// @return | boolean | True when the node has been visited.
        methods.add_method("hasVisited", |_, this, node_id: String| {
            Ok(this.inner.borrow().has_visited(&node_id))
        });
        // -- visitCount --
        /// Returns the number of visited nodes.
        /// @return | integer | Count of visited nodes.
        methods.add_method("visitCount", |_, this, ()| {
            Ok(this.inner.borrow().visit_count())
        });
        // -- isActive --
        /// Returns whether the conversation is currently active.
        /// @return | boolean | True when conversation is active.
        methods.add_method("isActive", |_, this, ()| {
            Ok(this.inner.borrow().is_active())
        });
        // -- setVariable --
        /// Sets a conversation variable for this object.
        /// @param | key | string | Variable name.
        /// @param | value | string | Variable value.
        methods.add_method("setVariable", |_, this, (key, value): (String, String)| {
            this.inner.borrow_mut().set_variable(key, value);
            Ok(())
        });
        // -- getVariable --
        /// Gets a conversation variable by key.
        /// @param | key | string | Variable name.
        /// @return | string | Variable value, or nil when the variable is not set.
        methods.add_method("getVariable", |_, this, key: String| {
            Ok(this
                .inner
                .borrow()
                .get_variable(&key)
                .map(|s| s.to_string()))
        });
        // -- reset --
        /// Reset all conversation progress, history, and visited flags.
        methods.add_method("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | The string `LDialogueState`.
        methods.add_method("type", |_, _, ()| Ok("LDialogueState"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True when the type name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDialogueState" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaSpeakerRegistry {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- add --
        /// Registers a speaker in the registry.
        /// @param | id | string | Unique speaker identifier.
        /// @param | name | string | Display name.
        /// @param | portrait | string? | Optional portrait asset path.
        /// @param | voice_id | string? | Optional voice identifier.
        methods.add_method(
            "add",
            |_, this, (id, name, portrait, voice_id): (String, String, Option<String>, Option<String>)| {
                let mut speaker = Speaker::new(id, name);
                speaker.portrait = portrait;
                speaker.voice_id = voice_id;
                this.inner.borrow_mut().add(speaker);
                Ok(())
            },
        );
        // -- get --
        /// Gets a speaker by ID as a table with id, name, portrait, voice_id fields.
        /// @param | id | string | Speaker identifier.
        /// @return | table | Speaker info table, or nil when the speaker ID is not found.
        methods.add_method("get", |lua, this, id: String| {
            match this.inner.borrow().get(&id) {
                Some(s) => {
                    let tbl = lua.create_table()?;
                    tbl.set("id", s.id.clone())?;
                    tbl.set("name", s.name.clone())?;
                    tbl.set("portrait", s.portrait.clone())?;
                    tbl.set("voice_id", s.voice_id.clone())?;
                    Ok(LuaValue::Table(tbl))
                }
                None => Ok(LuaValue::Nil),
            }
        });
        // -- remove --
        /// Removes a speaker by ID for this object.
        /// @param | id | string | Speaker identifier.
        /// @return | boolean | True when the speaker was found and removed.
        methods.add_method("remove", |_, this, id: String| {
            Ok(this.inner.borrow_mut().remove(&id).is_some())
        });
        // -- count --
        /// Returns the number of registered speakers.
        /// @return | integer | Speaker count.
        methods.add_method("count", |_, this, ()| Ok(this.inner.borrow().count()));
        // -- contains --
        /// Checks if a speaker exists in the registry.
        /// @param | id | string | Speaker identifier.
        /// @return | boolean | True when the speaker exists.
        methods.add_method("contains", |_, this, id: String| {
            Ok(this.inner.borrow().contains(&id))
        });
        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | The string `LSpeakerRegistry`.
        methods.add_method("type", |_, _, ()| Ok("LSpeakerRegistry"));
        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True when the type name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LSpeakerRegistry" || name == "LObject")
        });
    }
}

impl LuaUserData for LuaDialogSequencer {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- load --
        /// Loads a sequence of dialog nodes for playback.
        /// @param | nodes | table | Array of node tables created via lurek.dialog.say(), choice(), etc.
        methods.add_method_mut("load", |_lua, this, nodes: LuaTable| {
            let mut seq_nodes = Vec::new();
            for i in 1..=nodes.len()? {
                let node_tbl: LuaTable = nodes.get(i)?;
                let node_type: String = node_tbl.get("type")?;

                let node = match node_type.as_str() {
                    "say" => {
                        let actor = node_tbl.get("actor")?;
                        let text = node_tbl.get("text")?;
                        let duration = node_tbl.get("duration").ok();
                        SequencerNode::Say {
                            actor,
                            text,
                            duration,
                        }
                    }
                    "choice" => {
                        let prompt = node_tbl.get("prompt")?;
                        let options_tbl: LuaTable = node_tbl.get("options")?;
                        let mut options = Vec::new();
                        for j in 1..=options_tbl.len()? {
                            options.push(options_tbl.get(j)?);
                        }
                        SequencerNode::Choice { prompt, options }
                    }
                    "wait" => {
                        let seconds = node_tbl.get("seconds")?;
                        SequencerNode::Wait { seconds }
                    }
                    "event" => {
                        let name = node_tbl.get("name")?;
                        let data = node_tbl.get("data").ok();
                        SequencerNode::Event { name, data }
                    }
                    "call" => {
                        let name = node_tbl.get("name")?;
                        SequencerNode::Call { name }
                    }
                    "label" => {
                        let name = node_tbl.get("name")?;
                        SequencerNode::Label { name }
                    }
                    "jump" => {
                        let target = node_tbl.get("target")?;
                        SequencerNode::Jump { target }
                    }
                    _ => {
                        return Err(LuaError::RuntimeError(format!(
                            "Unknown node type: {}",
                            node_type
                        )));
                    }
                };
                seq_nodes.push(node);
            }
            this.inner.borrow_mut().load(seq_nodes);
            Ok(())
        });

        // -- start --
        /// Starts playback from the beginning of the loaded sequence.
        methods.add_method_mut("start", |_, this, ()| {
            this.inner.borrow_mut().start();
            Ok(())
        });

        // -- update --
        /// Advances the sequencer by dt seconds, updating typewriter reveal.
        /// @param | dt | number | Delta time in seconds.
        methods.add_method_mut("update", |_, this, dt: f32| {
            this.inner.borrow_mut().update(dt);
            Ok(())
        });

        // -- advance --
        /// Skips to the next node (or instantly reveals current line if typing).
        methods.add_method_mut("advance", |_, this, ()| {
            this.inner.borrow_mut().advance();
            Ok(())
        });

        // -- skip --
        /// Instantly reveals the full current line without typewriter effect.
        methods.add_method_mut("skip", |_, this, ()| {
            this.inner.borrow_mut().skip();
            Ok(())
        });

        // -- choose --
        /// Selects a choice option when waiting for choice input.
        /// @param | index | integer | Option index (1-based) to select.
        methods.add_method_mut("choose", |_, this, index: i64| {
            if index > 0 {
                this.inner.borrow_mut().choose((index - 1) as usize);
            }
            Ok(())
        });

        // -- setSpeed --
        /// Sets the typewriter reveal speed in characters per second.
        /// @param | cps | number | Characters per second.
        methods.add_method_mut("setSpeed", |_, this, cps: f32| {
            this.inner.borrow_mut().set_speed(cps);
            Ok(())
        });

        // -- getSpeed --
        /// Gets the current typewriter speed in characters per second.
        /// @return | number | Characters per second.
        methods.add_method("getSpeed", |_, this, ()| {
            Ok(this.inner.borrow().get_speed())
        });

        // -- getState --
        /// Returns the current playback state as a string.
        /// @return | string | One of: "idle", "typing", "waiting", "choice", "done".
        methods.add_method("getState", |_, this, ()| {
            Ok(this.inner.borrow().get_state().to_string())
        });

        // -- isActive --
        /// Checks if the sequencer is currently playing.
        /// @return | boolean | True when not idle or done.
        methods.add_method("isActive", |_, this, ()| {
            Ok(this.inner.borrow().is_active())
        });

        // -- isWaitingForChoice --
        /// Checks if the sequencer is waiting for a choice selection.
        /// @return | boolean | True when waiting for player choice.
        methods.add_method("isWaitingForChoice", |_, this, ()| {
            Ok(this.inner.borrow().is_waiting_for_choice())
        });

        // -- currentSpeaker --
        /// Returns the actor name for the current line, or nil.
        /// @return | string | Actor name, or nil.
        methods.add_method("currentSpeaker", |_, this, ()| {
            Ok(this.inner.borrow().current_speaker().map(|s| s.to_string()))
        });

        // -- currentText --
        /// Returns the full text of the current line.
        /// @return | string | Full line text.
        methods.add_method("currentText", |_, this, ()| {
            Ok(this.inner.borrow().current_text().to_string())
        });

        // -- revealedText --
        /// Returns only the typewriter-revealed portion of the current line.
        /// @return | string | Revealed text.
        methods.add_method("revealedText", |_, this, ()| {
            Ok(this.inner.borrow().revealed_text().to_string())
        });

        // -- getChoiceText --
        /// Returns the choice prompt text, or nil if not in a choice node.
        /// @return | string | Choice prompt, or nil.
        methods.add_method("getChoiceText", |_, this, ()| {
            Ok(this.inner.borrow().get_choice_text().map(|s| s.to_string()))
        });

        // -- getChoiceLabels --
        /// Returns an array of choice option labels.
        /// @return | table | Array of choice strings.
        methods.add_method("getChoiceLabels", |lua, this, ()| {
            let binding = this.inner.borrow();
            let labels = binding.get_choice_labels();
            let tbl = lua.create_table()?;
            for (i, label) in labels.iter().enumerate() {
                tbl.set(i + 1, label.clone())?;
            }
            Ok(tbl)
        });

        // -- type --
        /// Returns the Lua-visible type name.
        /// @return | string | The string `LDialogSequencer`.
        methods.add_method("type", |_, _, ()| Ok("LDialogSequencer"));

        // -- typeOf --
        /// Returns whether this handle matches a supported type name.
        /// @param | name | string | Type name to compare.
        /// @return | boolean | True when the type name matches.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LDialogSequencer" || name == "LObject")
        });
    }
}

/// Registers the `lurek.dialog` namespace on the given lurek table.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let dialog_table = lua.create_table()?;

    // -- newAI --
    /// Creates an empty dialogue selector for weighted topics and branches.
    /// @return | LDialogueAI | New dialogue AI handle.
    dialog_table.set(
        "newAI",
        lua.create_function(|_, ()| {
            Ok(LuaDialogueAI {
                inner: Rc::new(RefCell::new(DialogueAI::new())),
            })
        })?,
    )?;

    // -- newState --
    /// Creates an empty dialogue state for tracking conversation progress.
    /// @return | LDialogueState | New dialogue state handle.
    dialog_table.set(
        "newState",
        lua.create_function(|_, ()| {
            Ok(LuaDialogueState {
                inner: Rc::new(RefCell::new(DialogueState::new())),
            })
        })?,
    )?;

    // -- newSpeakerRegistry --
    /// Creates an empty speaker registry for dialog participants.
    /// @return | LSpeakerRegistry | New speaker registry handle.
    dialog_table.set(
        "newSpeakerRegistry",
        lua.create_function(|_, ()| {
            Ok(LuaSpeakerRegistry {
                inner: Rc::new(RefCell::new(SpeakerRegistry::new())),
            })
        })?,
    )?;

    // -- newSequencer --
    /// Creates an empty dialog sequencer for typewriter-style playback.
    /// @return | LDialogSequencer | New sequencer handle.
    dialog_table.set(
        "newSequencer",
        lua.create_function(|_, ()| {
            Ok(LuaDialogSequencer {
                inner: Rc::new(RefCell::new(DialogSequencer::new())),
            })
        })?,
    )?;

    // -- say --
    /// Creates a Say node for character dialog.
    /// @param | actor | string | Character name.
    /// @param | text | string | Dialog text.
    /// @param | opts | table? | Optional table with duration field.
    /// @return | table | Say node table for sequencer.load().
    dialog_table.set(
        "say",
        lua.create_function(
            |lua, (actor, text, opts): (String, String, Option<LuaTable>)| {
                let node = lua.create_table()?;
                node.set("type", "say")?;
                node.set("actor", actor)?;
                node.set("text", text)?;
                if let Some(o) = opts {
                    if let Ok(duration) = o.get::<_, f32>("duration") {
                        node.set("duration", duration)?;
                    }
                }
                Ok(node)
            },
        )?,
    )?;

    // -- choice --
    /// Creates a Choice node with selectable options.
    /// @param | prompt | string | Choice prompt text.
    /// @param | options | table | Array of option strings.
    /// @param | opts | table? | Optional table (reserved for future use).
    /// @return | table | Choice node table for sequencer.load().
    dialog_table.set(
        "choice",
        lua.create_function(
            |lua, (prompt, options, _opts): (String, LuaTable, Option<LuaTable>)| {
                let node = lua.create_table()?;
                node.set("type", "choice")?;
                node.set("prompt", prompt)?;
                node.set("options", options)?;
                Ok(node)
            },
        )?,
    )?;

    // -- wait --
    /// Creates a Wait node (delay before continuing).
    /// @param | seconds | number | Seconds to wait.
    /// @param | opts | table? | Optional table (reserved for future use).
    /// @return | table | Wait node table for sequencer.load().
    dialog_table.set(
        "wait",
        lua.create_function(|lua, (seconds, _opts): (f32, Option<LuaTable>)| {
            let node = lua.create_table()?;
            node.set("type", "wait")?;
            node.set("seconds", seconds)?;
            Ok(node)
        })?,
    )?;

    // -- event --
    /// Creates an Event node (fires a named callback).
    /// @param | name | string | Event name.
    /// @param | data | string? | Optional event payload.
    /// @param | opts | table? | Optional table (reserved for future use).
    /// @return | table | Event node table for sequencer.load().
    dialog_table.set(
        "event",
        lua.create_function(
            |lua, (name, data, _opts): (String, Option<String>, Option<LuaTable>)| {
                let node = lua.create_table()?;
                node.set("type", "event")?;
                node.set("name", name)?;
                if let Some(d) = data {
                    node.set("data", d)?;
                }
                Ok(node)
            },
        )?,
    )?;

    // -- call --
    /// Creates a Call node (invokes a Lua function by name).
    /// @param | fn_name | string | Lua function name to call.
    /// @param | opts | table? | Optional table (reserved for future use).
    /// @return | table | Call node table for sequencer.load().
    dialog_table.set(
        "call",
        lua.create_function(|lua, (name, _opts): (String, Option<LuaTable>)| {
            let node = lua.create_table()?;
            node.set("type", "call")?;
            node.set("name", name)?;
            Ok(node)
        })?,
    )?;

    // -- jump --
    /// Creates a Jump node (branches to a labeled position).
    /// @param | target | string | Label name to jump to.
    /// @param | opts | table? | Optional table (reserved for future use).
    /// @return | table | Jump node table for sequencer.load().
    dialog_table.set(
        "jump",
        lua.create_function(|lua, (target, _opts): (String, Option<LuaTable>)| {
            let node = lua.create_table()?;
            node.set("type", "jump")?;
            node.set("target", target)?;
            Ok(node)
        })?,
    )?;

    lurek.set("dialog", dialog_table)?;
    Ok(())
}
