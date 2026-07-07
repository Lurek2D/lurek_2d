//! Registers the `lurek.dialog` Lua API for dialog userdata, action control, and script-managed dialog flows.

use crate::dialog::{
    DialogHistoryEntry, DialogLineMeta, DialogSequencer, DialogSequencerSnapshot, DialogSignal,
    DialogueAI, DialogueState, SequencerNode, Speaker, SpeakerRegistry,
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

fn tags_from_opts(opts: &LuaTable, field: &str) -> LuaResult<Vec<String>> {
    let Ok(tags_tbl) = opts.get::<_, LuaTable>(field) else {
        return Ok(Vec::new());
    };
    let mut tags = Vec::new();
    for index in 1..=tags_tbl.len()? {
        tags.push(tags_tbl.get(index)?);
    }
    Ok(tags)
}

fn line_meta_from_opts(opts: Option<&LuaTable>) -> LuaResult<DialogLineMeta> {
    let Some(opts) = opts else {
        return Ok(DialogLineMeta::default());
    };
    Ok(DialogLineMeta {
        id: opts.get("id").ok(),
        voice: opts.get("voice").ok(),
        route: opts.get("route").ok(),
        tags: tags_from_opts(opts, "tags")?,
    })
}

fn node_from_lua(node_tbl: &LuaTable) -> LuaResult<SequencerNode> {
    let node_type: String = node_tbl.get("type")?;
    match node_type.as_str() {
        "say" => {
            let actor = node_tbl.get("actor")?;
            let text = node_tbl.get("text")?;
            let duration = node_tbl.get("duration").ok();
            let meta = line_meta_from_opts(Some(node_tbl))?;
            Ok(SequencerNode::Say {
                actor,
                text,
                duration,
                id: meta.id,
                voice: meta.voice,
                route: meta.route,
                tags: meta.tags,
            })
        }
        "choice" => {
            let prompt = node_tbl.get("prompt")?;
            let options_tbl: LuaTable = node_tbl.get("options")?;
            let mut options = Vec::new();
            for j in 1..=options_tbl.len()? {
                options.push(options_tbl.get(j)?);
            }
            Ok(SequencerNode::Choice { prompt, options })
        }
        "wait" => Ok(SequencerNode::Wait {
            seconds: node_tbl.get("seconds")?,
        }),
        "event" => Ok(SequencerNode::Event {
            name: node_tbl.get("name")?,
            data: node_tbl.get("data").ok(),
        }),
        "call" => Ok(SequencerNode::Call {
            name: node_tbl.get("name")?,
        }),
        "label" => Ok(SequencerNode::Label {
            name: node_tbl.get("name")?,
        }),
        "jump" => Ok(SequencerNode::Jump {
            target: node_tbl.get("target")?,
        }),
        _ => Err(LuaError::RuntimeError(format!(
            "Unknown node type: {}",
            node_type
        ))),
    }
}

fn apply_meta_to_node(lua: &Lua, node: &LuaTable, meta: &DialogLineMeta) -> LuaResult<()> {
    if let Some(id) = meta.id.as_ref() {
        node.set("id", id.clone())?;
    }
    if let Some(voice) = meta.voice.as_ref() {
        node.set("voice", voice.clone())?;
    }
    if let Some(route) = meta.route.as_ref() {
        node.set("route", route.clone())?;
    }
    if !meta.tags.is_empty() {
        let tags = lua.create_table()?;
        for (index, tag) in meta.tags.iter().enumerate() {
            tags.set(index + 1, tag.clone())?;
        }
        node.set("tags", tags)?;
    }
    Ok(())
}

fn node_to_lua<'lua>(lua: &'lua Lua, node: &SequencerNode) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    match node {
        SequencerNode::Say {
            actor,
            text,
            duration,
            id,
            voice,
            route,
            tags,
        } => {
            table.set("type", "say")?;
            table.set("actor", actor.as_str())?;
            table.set("text", text.as_str())?;
            if let Some(duration) = duration {
                table.set("duration", *duration)?;
            }
            apply_meta_to_node(
                lua,
                &table,
                &DialogLineMeta {
                    id: id.clone(),
                    voice: voice.clone(),
                    route: route.clone(),
                    tags: tags.clone(),
                },
            )?;
        }
        SequencerNode::Choice { prompt, options } => {
            table.set("type", "choice")?;
            table.set("prompt", prompt.as_str())?;
            let options_tbl = lua.create_table()?;
            for (index, option) in options.iter().enumerate() {
                options_tbl.set(index + 1, option.as_str())?;
            }
            table.set("options", options_tbl)?;
        }
        SequencerNode::Wait { seconds } => {
            table.set("type", "wait")?;
            table.set("seconds", *seconds)?;
        }
        SequencerNode::Event { name, data } => {
            table.set("type", "event")?;
            table.set("name", name.as_str())?;
            if let Some(data) = data.as_ref() {
                table.set("data", data.as_str())?;
            }
        }
        SequencerNode::Call { name } => {
            table.set("type", "call")?;
            table.set("name", name.as_str())?;
        }
        SequencerNode::Label { name } => {
            table.set("type", "label")?;
            table.set("name", name.as_str())?;
        }
        SequencerNode::Jump { target } => {
            table.set("type", "jump")?;
            table.set("target", target.as_str())?;
        }
    }
    Ok(table)
}

fn history_entry_to_lua<'lua>(
    lua: &'lua Lua,
    entry: &DialogHistoryEntry,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("speaker", entry.speaker.clone())?;
    table.set("text", entry.text.clone())?;
    apply_meta_to_node(lua, &table, &entry.meta)?;
    Ok(table)
}

fn signal_to_lua<'lua>(lua: &'lua Lua, signal: &DialogSignal) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    table.set("kind", signal.kind.as_str())?;
    table.set("name", signal.name.as_str())?;
    table.set("data", signal.data.clone())?;
    Ok(table)
}

fn snapshot_to_lua<'lua>(
    lua: &'lua Lua,
    snapshot: &DialogSequencerSnapshot,
) -> LuaResult<LuaTable<'lua>> {
    let table = lua.create_table()?;
    let nodes = lua.create_table()?;
    for (index, node) in snapshot.nodes.iter().enumerate() {
        nodes.set(index + 1, node_to_lua(lua, node)?)?;
    }
    table.set("nodes", nodes)?;
    table.set("nextIndex", snapshot.current_index + 1)?;
    table.set("state", snapshot.state.as_str())?;
    table.set("revealedChars", snapshot.revealed_chars)?;
    table.set("elapsed", snapshot.elapsed)?;
    table.set("cps", snapshot.cps)?;
    if let Some(choice) = snapshot.current_choice {
        table.set("currentChoice", choice + 1)?;
    }
    table.set("choicePrompt", snapshot.choice_prompt.clone())?;
    let choice_labels = lua.create_table()?;
    for (index, label) in snapshot.choice_labels.iter().enumerate() {
        choice_labels.set(index + 1, label.clone())?;
    }
    table.set("choiceLabels", choice_labels)?;
    table.set("currentSpeaker", snapshot.current_speaker.clone())?;
    table.set("currentText", snapshot.current_text.clone())?;
    apply_meta_to_node(lua, &table, &snapshot.current_meta)?;
    table.set("waitRemaining", snapshot.wait_remaining)?;
    table.set("lineHoldRemaining", snapshot.line_hold_remaining)?;
    let history = lua.create_table()?;
    for (index, entry) in snapshot.history.iter().enumerate() {
        history.set(index + 1, history_entry_to_lua(lua, entry)?)?;
    }
    table.set("history", history)?;
    let signals = lua.create_table()?;
    for (index, signal) in snapshot.pending_signals.iter().enumerate() {
        signals.set(index + 1, signal_to_lua(lua, signal)?)?;
    }
    table.set("pendingSignals", signals)?;
    Ok(table)
}

fn snapshot_from_lua(snapshot: LuaTable) -> LuaResult<DialogSequencerSnapshot> {
    let nodes_tbl: LuaTable = snapshot.get("nodes")?;
    let mut nodes = Vec::new();
    for index in 1..=nodes_tbl.len()? {
        nodes.push(node_from_lua(&nodes_tbl.get::<_, LuaTable>(index)?)?);
    }

    let mut history = Vec::new();
    if let Some(history_tbl) = snapshot.get::<_, Option<LuaTable>>("history")? {
        for index in 1..=history_tbl.len()? {
            let entry: LuaTable = history_tbl.get(index)?;
            history.push(DialogHistoryEntry {
                speaker: entry.get("speaker").ok(),
                text: entry.get("text")?,
                meta: line_meta_from_opts(Some(&entry))?,
            });
        }
    }

    let mut pending_signals = Vec::new();
    if let Some(signals_tbl) = snapshot.get::<_, Option<LuaTable>>("pendingSignals")? {
        for index in 1..=signals_tbl.len()? {
            let signal: LuaTable = signals_tbl.get(index)?;
            pending_signals.push(DialogSignal {
                kind: signal.get("kind")?,
                name: signal.get("name")?,
                data: signal.get("data").ok(),
            });
        }
    }

    let mut choice_labels = Vec::new();
    if let Some(choice_labels_tbl) = snapshot.get::<_, Option<LuaTable>>("choiceLabels")? {
        for index in 1..=choice_labels_tbl.len()? {
            choice_labels.push(choice_labels_tbl.get(index)?);
        }
    }

    let current_choice = snapshot
        .get::<_, Option<usize>>("currentChoice")?
        .map(|value| value.saturating_sub(1));
    let next_index = snapshot.get::<_, Option<usize>>("nextIndex")?.unwrap_or(1);
    let current_meta = line_meta_from_opts(Some(&snapshot))?;
    let state_name = snapshot
        .get::<_, Option<String>>("state")?
        .unwrap_or_else(|| "idle".to_string());
    let state = match state_name.as_str() {
        "idle" => crate::dialog::SequencerState::Idle,
        "typing" => crate::dialog::SequencerState::Typing,
        "waiting" => crate::dialog::SequencerState::Waiting,
        "choice" => crate::dialog::SequencerState::WaitingForChoice,
        "done" => crate::dialog::SequencerState::Done,
        other => {
            return Err(LuaError::RuntimeError(format!(
                "Unknown sequencer state: {other}"
            )));
        }
    };

    Ok(DialogSequencerSnapshot {
        nodes,
        current_index: next_index.saturating_sub(1),
        state,
        revealed_chars: snapshot
            .get::<_, Option<usize>>("revealedChars")?
            .unwrap_or(0),
        elapsed: snapshot.get::<_, Option<f32>>("elapsed")?.unwrap_or(0.0),
        cps: snapshot.get::<_, Option<f32>>("cps")?.unwrap_or(60.0),
        current_choice,
        choice_prompt: snapshot.get("choicePrompt").ok(),
        choice_labels,
        current_speaker: snapshot.get("currentSpeaker").ok(),
        current_text: snapshot
            .get::<_, Option<String>>("currentText")?
            .unwrap_or_default(),
        current_meta,
        wait_remaining: snapshot
            .get::<_, Option<f32>>("waitRemaining")?
            .unwrap_or(0.0),
        line_hold_remaining: snapshot
            .get::<_, Option<f32>>("lineHoldRemaining")?
            .unwrap_or(0.0),
        history,
        pending_signals,
    })
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
            |_,
             this,
             (id, name, portrait, voice_id, opts): (
                String,
                String,
                Option<String>,
                Option<String>,
                Option<LuaTable>,
            )| {
                let mut speaker = Speaker::new(id, name);
                speaker.portrait = portrait;
                speaker.voice_id = voice_id;
                if let Some(opts) = opts {
                    speaker.tags = tags_from_opts(&opts, "tags")?;
                }
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
                    let tags = lua.create_table()?;
                    for (index, tag) in s.tags.iter().enumerate() {
                        tags.set(index + 1, tag.clone())?;
                    }
                    tbl.set("tags", tags)?;
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
                seq_nodes.push(node_from_lua(&node_tbl)?);
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

        // -- currentId --
        /// Returns the authored id of the current line, or nil when unset.
        /// @return | string | Current line id, or nil.
        methods.add_method("currentId", |_, this, ()| {
            Ok(this.inner.borrow().current_id().map(|s| s.to_string()))
        });

        // -- currentVoice --
        /// Returns the current line voice id, or nil when unset.
        /// @return | string | Current voice id, or nil.
        methods.add_method("currentVoice", |_, this, ()| {
            Ok(this.inner.borrow().current_voice().map(|s| s.to_string()))
        });

        // -- currentRoute --
        /// Returns the current line route marker, or nil when unset.
        /// @return | string | Current route marker, or nil.
        methods.add_method("currentRoute", |_, this, ()| {
            Ok(this.inner.borrow().current_route().map(|s| s.to_string()))
        });

        // -- currentTags --
        /// Returns the current line tag array.
        /// @return | table | Array of current line tags.
        methods.add_method("currentTags", |lua, this, ()| {
            let table = lua.create_table()?;
            for (index, tag) in this.inner.borrow().current_tags().iter().enumerate() {
                table.set(index + 1, tag.as_str())?;
            }
            Ok(table)
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

        // -- getHistory --
        /// Returns spoken-line history in insertion order.
        /// @return | table | Array of `{speaker,text,id?,voice?,route?,tags?}` entries.
        methods.add_method("getHistory", |lua, this, ()| {
            let table = lua.create_table()?;
            for (index, entry) in this.inner.borrow().history().iter().enumerate() {
                table.set(index + 1, history_entry_to_lua(lua, entry)?)?;
            }
            Ok(table)
        });

        // -- clearHistory --
        /// Clears accumulated spoken-line history.
        methods.add_method_mut("clearHistory", |_, this, ()| {
            this.inner.borrow_mut().clear_history();
            Ok(())
        });

        // -- peekSignal --
        /// Returns the next pending event/call signal without removing it.
        /// @return | table | `{kind,name,data?}`, or nil when no signal is pending.
        methods.add_method("peekSignal", |lua, this, ()| {
            match this.inner.borrow().peek_signal() {
                Some(signal) => Ok(LuaValue::Table(signal_to_lua(lua, signal)?)),
                None => Ok(LuaValue::Nil),
            }
        });

        // -- popSignal --
        /// Removes and returns the next pending event/call signal.
        /// @return | table | `{kind,name,data?}`, or nil when no signal is pending.
        methods.add_method_mut("popSignal", |lua, this, ()| {
            match this.inner.borrow_mut().pop_signal() {
                Some(signal) => Ok(LuaValue::Table(signal_to_lua(lua, &signal)?)),
                None => Ok(LuaValue::Nil),
            }
        });

        // -- snapshot --
        /// Captures sequencer runtime state, including nodes, progress, history, and pending signals.
        /// @return | table | Serializable snapshot table.
        methods.add_method("snapshot", |lua, this, ()| {
            snapshot_to_lua(lua, &this.inner.borrow().snapshot())
        });

        // -- restore --
        /// Restores sequencer runtime state from a prior snapshot table.
        /// @param | snapshot | table | Snapshot returned by `snapshot()`.
        methods.add_method_mut("restore", |_, this, snapshot: LuaTable| {
            this.inner
                .borrow_mut()
                .restore(snapshot_from_lua(snapshot)?);
            Ok(())
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
    /// @param | opts | table? | Optional table with `duration`, `id`, `voice`, `route`, and `tags`.
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
                    apply_meta_to_node(lua, &node, &line_meta_from_opts(Some(&o))?)?;
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

    // -- label --
    /// Creates a Label node used as a jump target marker.
    /// @param | name | string | Label name.
    /// @return | table | Label node table for sequencer.load().
    dialog_table.set(
        "label",
        lua.create_function(|lua, name: String| {
            let node = lua.create_table()?;
            node.set("type", "label")?;
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
