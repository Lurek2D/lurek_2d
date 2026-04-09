"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const server_js_1 = require("./mcp/server.js");
// Services
const lunaProcess_js_1 = require("./services/lunaProcess.js");
const statusBar_js_1 = require("./services/statusBar.js");
const apiData_js_1 = require("./services/apiData.js");
// Sidebar providers
const sidebar_js_1 = require("./providers/sidebar.js");
// Language providers
const completionProvider = __importStar(require("./providers/completion.js"));
const hoverProvider = __importStar(require("./providers/hover.js"));
const signatureProvider = __importStar(require("./providers/signature.js"));
const definitionProvider = __importStar(require("./providers/definition.js"));
const referencesProvider = __importStar(require("./providers/references.js"));
const symbolsProvider = __importStar(require("./providers/symbols.js"));
const diagnosticsProvider = __importStar(require("./providers/diagnostics.js"));
const colorProvider = __importStar(require("./providers/color.js"));
const assetPathProvider = __importStar(require("./providers/assetPath.js"));
const inlayHintsProvider = __importStar(require("./providers/inlayHints.js"));
const codeActionsProvider = __importStar(require("./providers/codeActions.js"));
// Phase 2b providers
const luajitHintsProvider = __importStar(require("./providers/luajitHints.js"));
const typeInferenceProvider = __importStar(require("./providers/typeInference.js"));
const requireGraphProvider = __importStar(require("./providers/requireGraph.js"));
const symbolIndexService = __importStar(require("./services/symbolIndex.js"));
// Phase 3 providers
const formatting_js_1 = require("./providers/formatting.js");
const folding_js_1 = require("./providers/folding.js");
const rename_js_1 = require("./providers/rename.js");
const semanticTokens_js_1 = require("./providers/semanticTokens.js");
// New providers (Phase 4+)
const luacatsProvider = __importStar(require("./providers/luacatsProvider.js"));
const assetExplorer_js_1 = require("./providers/assetExplorer.js");
const perfDashboard_js_1 = require("./providers/perfDashboard.js");
const codeLensProvider = __importStar(require("./providers/codeLens.js"));
const debugWatchers_js_1 = require("./providers/debugWatchers.js");
const systemMonitor_js_1 = require("./providers/systemMonitor.js");
const apiUsage_js_1 = require("./providers/apiUsage.js");
// Commands
const run_js_1 = require("./commands/run.js");
const scaffold_js_1 = require("./commands/scaffold.js");
const test_js_1 = require("./commands/test.js");
const packaging_js_1 = require("./commands/packaging.js");
const editors_js_1 = require("./commands/editors.js");
const reference_js_1 = require("./commands/reference.js");
const cag_js_1 = require("./commands/cag.js");
const testGenerator_js_1 = require("./commands/testGenerator.js");
const debugBridge_js_1 = require("./services/debugBridge.js");
const debugBridge_js_2 = require("./commands/debugBridge.js");
const gameJam_js_1 = require("./commands/gameJam.js");
const library_js_1 = require("./commands/library.js");
const gameDevCag_js_1 = require("./commands/gameDevCag.js");
const luaDebugAdapter_js_1 = require("./debug/luaDebugAdapter.js");
/** MCP server handle. */
let mcpProcess;
/** Shared services. */
let lunaProcess;
let statusBar;
let apiData;
let debugBridge;
/**
 * Activates the Luna Toolkit extension.
 */
function activate(context) {
    // ─── Services ────────────────────────────────────────────
    lunaProcess = new lunaProcess_js_1.LunaProcessService();
    statusBar = new statusBar_js_1.StatusBarService();
    apiData = new apiData_js_1.ApiDataService();
    debugBridge = new debugBridge_js_1.DebugBridge();
    context.subscriptions.push(lunaProcess, statusBar, debugBridge);
    // Load API data asynchronously (providers work with partial data until loaded)
    apiData.load(context.extensionPath).catch((err) => {
        console.error("Failed to load Luna API data:", err);
    });
    // Wire status bar to process events
    lunaProcess.onStatusChange((running) => {
        if (running) {
            statusBar.setRunning();
        }
        else {
            statusBar.setStopped();
        }
    });
    // ─── Sidebar Tree Views ──────────────────────────────────
    const projectTools = new sidebar_js_1.ProjectToolsProvider();
    const devTools = new sidebar_js_1.DevToolsProvider();
    const aiTools = new sidebar_js_1.AiToolsProvider();
    context.subscriptions.push(vscode.window.registerTreeDataProvider("luna.projectTools", projectTools), vscode.window.registerTreeDataProvider("luna.devTools", devTools), vscode.window.registerTreeDataProvider("luna.aiCopilot", aiTools));
    // ─── Language Providers (IntelliSense) ───────────────────
    completionProvider.register(context, apiData);
    hoverProvider.register(context, apiData);
    signatureProvider.register(context, apiData);
    definitionProvider.register(context, apiData);
    referencesProvider.register(context, apiData);
    symbolsProvider.register(context, apiData);
    diagnosticsProvider.register(context, apiData);
    colorProvider.register(context, apiData);
    assetPathProvider.register(context, apiData);
    inlayHintsProvider.register(context, apiData);
    codeActionsProvider.register(context, apiData);
    // Phase 2b: Enhanced IntelliSense providers
    luajitHintsProvider.register(context, apiData);
    typeInferenceProvider.register(context, apiData);
    requireGraphProvider.register(context);
    symbolIndexService.register(context);
    // LuaCATS @class/@field annotation hover and completion
    luacatsProvider.register(context, apiData);
    // Phase 3: Formatting, folding, rename, semantic tokens
    (0, formatting_js_1.register)(context, apiData);
    (0, folding_js_1.register)(context, apiData);
    (0, rename_js_1.register)(context, apiData);
    (0, semanticTokens_js_1.register)(context, apiData);
    // ─── Asset Explorer Tree View ────────────────────────────
    const assetExplorer = new assetExplorer_js_1.AssetExplorerProvider();
    context.subscriptions.push(vscode.window.registerTreeDataProvider("luna.assetExplorer", assetExplorer));
    // ─── Run Commands ────────────────────────────────────────
    registerCommand(context, "luna.runGame", () => (0, run_js_1.runGame)(lunaProcess));
    registerCommand(context, "luna.stopGame", () => (0, run_js_1.stopGame)(lunaProcess));
    registerCommand(context, "luna.runWithArgs", () => (0, run_js_1.runWithArgs)(lunaProcess));
    registerCommand(context, "luna.runExample", () => (0, run_js_1.runExample)(lunaProcess));
    // ─── Test Commands ───────────────────────────────────────
    registerCommand(context, "luna.test.all", () => (0, test_js_1.testAll)());
    // Rust module tests
    const rustModules = [
        "ai", "audio", "cardgame", "combat", "compute", "config", "crafting",
        "data", "dataframe", "dialog", "engine", "entity", "event", "filesystem",
        "graph", "graphics", "graphics_ext", "image", "input", "inventory",
        "math", "math_ext", "minimap", "modding", "particle", "pathfinding",
        "physics", "postfx", "quest", "resource", "savegame", "scene", "sound",
        "stats", "thread", "tilemap", "timer",
    ];
    for (const mod of rustModules) {
        registerCommand(context, `luna.test.rust.${mod}`, () => (0, test_js_1.testModule)(mod));
    }
    registerCommand(context, "luna.test.lua.all", () => (0, test_js_1.testLuaAll)());
    registerCommand(context, "luna.test.lua.golden", () => (0, test_js_1.testLuaGolden)());
    // Test generator commands (Phase 4)
    (0, testGenerator_js_1.registerTestCommands)(context);
    // ─── Scaffold Commands ───────────────────────────────────
    registerCommand(context, "luna.scaffold.project", () => (0, scaffold_js_1.scaffoldProject)());
    registerCommand(context, "luna.scaffold.file", () => (0, scaffold_js_1.scaffoldFile)());
    // ─── Refactor Commands ───────────────────────────────────
    registerCommand(context, "luna.extractToModuleFile", async (...args) => {
        const uri = args[0];
        const range = args[1];
        if (!uri || !range)
            return;
        const moduleName = await vscode.window.showInputBox({
            prompt: "New module file name (without .lua)",
            placeHolder: "my_module",
            validateInput: v => /^[a-z_][a-z0-9_]*$/i.test(v) ? null : "Use letters, digits, underscores",
        });
        if (!moduleName)
            return;
        const doc = await vscode.workspace.openTextDocument(uri);
        const selectedText = doc.getText(range);
        const folder = uri.fsPath.replace(/[/\\][^/\\]+$/, "");
        const newUri = vscode.Uri.file(`${folder}/${moduleName}.lua`);
        const we = new vscode.WorkspaceEdit();
        we.createFile(newUri, { ignoreIfExists: true });
        we.insert(newUri, new vscode.Position(0, 0), `-- ${moduleName}.lua\nlocal M = {}\n\n${selectedText}\n\nreturn M\n`);
        we.replace(uri, range, `require("${moduleName}")`);
        await vscode.workspace.applyEdit(we);
        await vscode.window.showTextDocument(newUri);
    });
    // ─── Package Commands ────────────────────────────────────
    registerCommand(context, "luna.package.zip", () => (0, packaging_js_1.packageZip)());
    registerCommand(context, "luna.package.windows", () => (0, packaging_js_1.packageWindows)());
    registerCommand(context, "luna.package.linux", () => (0, packaging_js_1.packageLinux)());
    // ─── Editor Commands ─────────────────────────────────────
    context.subscriptions.push(...(0, editors_js_1.registerEditorCommands)(context));
    // ─── Asset Explorer Commands ─────────────────────────────
    registerCommand(context, "luna.assets.refresh", () => assetExplorer.refresh());
    registerCommand(context, "luna.assets.openPanel", () => {
        vscode.window.showInformationMessage("Asset Explorer is in the sidebar under Luna2D.");
    });
    registerCommand(context, "luna.assets.findMissing", () => (0, assetExplorer_js_1.findMissingAssets)());
    registerCommand(context, "luna.assets.insertPath", (item) => {
        if (item instanceof assetExplorer_js_1.AssetItem)
            (0, assetExplorer_js_1.insertAssetPath)(item);
    });
    // ─── Performance Dashboard Commands ─────────────────────
    registerCommand(context, "luna.perf.openDashboard", () => (0, perfDashboard_js_1.openPerfDashboard)(context));
    registerCommand(context, "luna.perf.clearHistory", () => {
        const { clearHistory } = require("./providers/perfDashboard.js");
        clearHistory();
    });
    registerCommand(context, "luna.perf.openHotReload", () => {
        const panel = vscode.window.createWebviewPanel("luna.hotReload", "Hot-Reload History", vscode.ViewColumn.Two, { enableScripts: true, retainContextWhenHidden: true });
        const events = [];
        const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? "";
        const watcher = vscode.workspace.createFileSystemWatcher(new vscode.RelativePattern(wsRoot, "**/*.lua"));
        const push = (file, status) => {
            events.unshift({ time: new Date().toLocaleTimeString(), file: vscode.workspace.asRelativePath(file), status });
            if (events.length > 200)
                events.pop();
            panel.webview.postMessage({ type: "events", events });
        };
        watcher.onDidChange((u) => push(u, "changed"));
        watcher.onDidCreate((u) => push(u, "created"));
        watcher.onDidDelete((u) => push(u, "deleted"));
        panel.onDidDispose(() => watcher.dispose());
        panel.webview.html = `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline';"><style>body{font-family:var(--vscode-font-family);background:var(--vscode-editor-background);color:var(--vscode-foreground);padding:12px;margin:0;font-size:12px}h2{margin:0 0 10px;font-size:14px}table{border-collapse:collapse;width:100%}th,td{border:1px solid var(--vscode-panel-border,#444);padding:4px 8px;text-align:left}th{background:var(--vscode-editorWidget-background,#1e1e1e)}.changed{color:#4ec9b0}.created{color:#dcdcaa}.deleted{color:#f44747}#empty{opacity:.5;margin-top:20px}</style></head><body><h2>\uD83D\uDD04 Hot-Reload File Watcher</h2><p id="empty">Watching *.lua files \u2014 save a file to see events here.</p><table id="tbl" style="display:none"><thead><tr><th>Time</th><th>File</th><th>Status</th></tr></thead><tbody id="body"></tbody></table><script>window.addEventListener('message',e=>{const{events}=e.data;if(!events||!events.length)return;document.getElementById('empty').style.display='none';document.getElementById('tbl').style.display='';document.getElementById('body').innerHTML=events.map(ev=>'<tr><td>'+ev.time+'</td><td>'+ev.file+'</td><td class="'+ev.status+'">'+ev.status+'</td></tr>').join('');});<\/script></body></html>`;
    });
    // ─── Dependency Graph Commands ───────────────────────────
    registerCommand(context, "luna.deps.showGraph", () => (0, reference_js_1.depGraph)(context));
    registerCommand(context, "luna.deps.findCircular", async () => {
        const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
        if (!wsRoot) {
            vscode.window.showErrorMessage("No workspace folder open.");
            return;
        }
        const out = vscode.window.createOutputChannel("Luna Circular Deps");
        out.show(true);
        out.appendLine("\uD83D\uDD0D Scanning for circular dependencies...");
        const nodeFsModule = require("fs");
        const nodePathModule = require("path");
        const srcDir = nodePathModule.join(wsRoot, "src");
        if (!nodeFsModule.existsSync(srcDir)) {
            out.appendLine("src/ directory not found.");
            return;
        }
        const modules = nodeFsModule.readdirSync(srcDir, { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name);
        const adj = {};
        for (const mod of modules) {
            adj[mod] = [];
            const modFile = nodePathModule.join(srcDir, mod, "mod.rs");
            if (!nodeFsModule.existsSync(modFile))
                continue;
            const src = nodeFsModule.readFileSync(modFile, "utf-8");
            for (const m of src.matchAll(/use crate::([a-z_]+)/g)) {
                if (m[1] !== mod && modules.includes(m[1]) && !adj[mod].includes(m[1]))
                    adj[mod].push(m[1]);
            }
        }
        const indexMap = {}, lowlink = {}, onStack = {}, stack = [];
        let idx = 0;
        const sccs = [];
        function strongconnect(v) {
            indexMap[v] = lowlink[v] = idx++;
            stack.push(v);
            onStack[v] = true;
            for (const w of (adj[v] || [])) {
                if (indexMap[w] === undefined) {
                    strongconnect(w);
                    lowlink[v] = Math.min(lowlink[v], lowlink[w]);
                }
                else if (onStack[w]) {
                    lowlink[v] = Math.min(lowlink[v], indexMap[w]);
                }
            }
            if (lowlink[v] === indexMap[v]) {
                const scc = [];
                let w;
                do {
                    w = stack.pop();
                    onStack[w] = false;
                    scc.push(w);
                } while (w !== v);
                if (scc.length > 1)
                    sccs.push(scc);
            }
        }
        for (const v of modules) {
            if (indexMap[v] === undefined)
                strongconnect(v);
        }
        if (sccs.length === 0) {
            out.appendLine("\u2705 No circular dependencies found.");
        }
        else {
            out.appendLine(`\u26A0\uFE0F  Found ${sccs.length} circular dependency cycle(s):`);
            sccs.forEach((scc, i) => out.appendLine(`  Cycle ${i + 1}: ${scc.join(" \u2192 ")} \u2192 ${scc[scc.length - 1]}`));
        }
        out.appendLine("\nDone.");
    });
    registerCommand(context, "luna.deps.findOrphans", async () => {
        const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
        if (!wsRoot) {
            vscode.window.showErrorMessage("No workspace folder open.");
            return;
        }
        const out = vscode.window.createOutputChannel("Luna Orphan Modules");
        out.show(true);
        out.appendLine("\uD83D\uDD0D Scanning for orphan modules...");
        const nodeFsModule = require("fs");
        const nodePathModule = require("path");
        const srcDir = nodePathModule.join(wsRoot, "src");
        if (!nodeFsModule.existsSync(srcDir)) {
            out.appendLine("src/ not found.");
            return;
        }
        const modules = nodeFsModule.readdirSync(srcDir, { withFileTypes: true }).filter((e) => e.isDirectory()).map((e) => e.name);
        const libRs = nodePathModule.join(wsRoot, "src", "lib.rs");
        const libContent = nodeFsModule.existsSync(libRs) ? nodeFsModule.readFileSync(libRs, "utf-8") : "";
        const referencedInLib = new Set(modules.filter((m) => libContent.includes(`pub mod ${m}`) || libContent.includes(`mod ${m}`)));
        const referencedByOthers = new Set();
        for (const mod of modules) {
            const modFile = nodePathModule.join(srcDir, mod, "mod.rs");
            if (!nodeFsModule.existsSync(modFile))
                continue;
            const src = nodeFsModule.readFileSync(modFile, "utf-8");
            for (const m of src.matchAll(/use crate::([a-z_]+)/g))
                if (m[1] !== mod)
                    referencedByOthers.add(m[1]);
        }
        const orphans = modules.filter((m) => !referencedInLib.has(m) && !referencedByOthers.has(m));
        if (orphans.length === 0) {
            out.appendLine("\u2705 No orphan modules found \u2014 all modules are referenced.");
        }
        else {
            out.appendLine(`\u26A0\uFE0F  Found ${orphans.length} potentially orphaned module(s):`);
            orphans.forEach((m) => out.appendLine(`  \u2022 ${m}`));
        }
        out.appendLine("\nDone.");
    });
    // ─── New Phase 5 providers ───────────────────────────────
    codeLensProvider.register(context, apiData);
    // ─── Debug Watchers + System Monitor ────────────────────
    registerCommand(context, "luna.debug.openWatchers", () => (0, debugWatchers_js_1.openWatchersPanel)(context));
    registerCommand(context, "luna.debug.openInspector", () => {
        const panel = vscode.window.createWebviewPanel("lunaVariableInspector", "Luna Variable Inspector", vscode.ViewColumn.Two, { enableScripts: true, retainContextWhenHidden: true });
        const getHtml = (entries) => `<!DOCTYPE html><html><head>
<meta charset="UTF-8">
<style>
  body{font-family:var(--vscode-font-family);font-size:13px;padding:12px;color:var(--vscode-editor-foreground);background:var(--vscode-editor-background)}
  h2{margin:0 0 10px;font-size:14px;color:var(--vscode-titleBar-activeForeground)}
  table{width:100%;border-collapse:collapse}
  th{background:var(--vscode-editor-selectionBackground);text-align:left;padding:6px 8px;font-size:12px}
  td{padding:5px 8px;border-bottom:1px solid var(--vscode-panel-border)}
  .type{color:var(--vscode-symbolIcon-typeForeground);font-size:11px}
  .val{color:var(--vscode-debugTokenExpression-value)}
  .empty{color:var(--vscode-disabledForeground);padding:16px;text-align:center}
  button{margin-top:12px;padding:5px 12px;background:var(--vscode-button-background);color:var(--vscode-button-foreground);border:none;cursor:pointer;border-radius:3px}
  button:hover{background:var(--vscode-button-hoverBackground)}
  .toolbar{display:flex;gap:8px;margin-bottom:12px}
  input{flex:1;padding:5px 8px;background:var(--vscode-input-background);border:1px solid var(--vscode-input-border);color:var(--vscode-input-foreground);border-radius:3px}
</style>
</head><body>
<h2>🔍 Variable Inspector</h2>
<div class="toolbar">
  <input id="expr" type="text" placeholder="Enter Lua expression, e.g. player.x" />
  <button onclick="addExpr()">Watch</button>
  <button onclick="clearAll()">Clear</button>
</div>
<table>
  <thead><tr><th>Expression</th><th>Value</th><th>Type</th></tr></thead>
  <tbody id="rows">${entries.length === 0
            ? '<tr><td colspan="3" class="empty">No watched expressions. Enter a Lua expression above.</td></tr>'
            : entries.map(e => `<tr><td>${e.expr}</td><td class="val">${e.value}</td><td class="type">${e.type}</td></tr>`).join("")}</tbody>
</table>
<script>
  const vscode = acquireVsCodeApi();
  function addExpr(){ const e=document.getElementById('expr'); if(e.value.trim()) vscode.postMessage({cmd:'watch',expr:e.value.trim()}); e.value=''; }
  function clearAll(){ vscode.postMessage({cmd:'clear'}); }
  document.getElementById('expr').addEventListener('keydown',e=>{ if(e.key==='Enter') addExpr(); });
  window.addEventListener('message',e=>{ if(e.data.cmd==='refresh') location.reload(); });
</script>
</body></html>`;
        const watches = [];
        panel.webview.html = getHtml(watches);
        panel.webview.onDidReceiveMessage(async (msg) => {
            if (msg.cmd === "watch") {
                // Try to evaluate against debug bridge if connected, else show placeholder
                let value = "(not connected — run game with debug bridge)";
                let type = "?";
                try {
                    const { DebugBridge } = await Promise.resolve().then(() => __importStar(require("./debug/debugBridge")));
                    if (DebugBridge.instance?.isConnected()) {
                        const result = await DebugBridge.instance.evaluate(msg.expr);
                        value = result?.resultString ?? "(nil)";
                        type = result?.luaType ?? "?";
                    }
                }
                catch (_) { /* bridge not available */ }
                watches.push({ expr: msg.expr, value, type });
                panel.webview.html = getHtml(watches);
            }
            else if (msg.cmd === "clear") {
                watches.length = 0;
                panel.webview.html = getHtml(watches);
            }
        }, undefined, context.subscriptions);
    });
    registerCommand(context, "luna.debug.openCallStack", () => {
        vscode.window.showInformationMessage("Call stack available when connected to the Lua debug bridge.");
    });
    registerCommand(context, "luna.debug.addWatch", () => {
        const editor = vscode.window.activeTextEditor;
        if (editor)
            (0, debugWatchers_js_1.addWatchFromEditor)(editor);
    });
    registerCommand(context, "luna.system.openMonitor", () => (0, systemMonitor_js_1.openSystemMonitor)(context));
    registerCommand(context, "luna.api.usageReport", () => (0, apiUsage_js_1.openApiUsageReport)(context));
    registerCommand(context, "luna.api.quickInsert", () => (0, apiUsage_js_1.quickInsertLunaApi)(apiData));
    registerCommand(context, "luna.codeLens.toggle", () => vscode.commands.executeCommand("luna.codeLens.toggle"));
    // Wire watchers to debug bridge events (if debug bridge exposes events)
    if (typeof debugBridge.onConnected === "function") {
        const bridge = debugBridge;
        bridge.onConnected(() => (0, debugWatchers_js_1.setConnected)(true));
        bridge.onDisconnected?.(() => (0, debugWatchers_js_1.setConnected)(false));
        if (bridge.evaluate) {
            (0, debugWatchers_js_1.setEvaluator)(async (expr) => {
                try {
                    const raw = await bridge.evaluate(expr);
                    return { value: String(raw), type: typeof raw };
                }
                catch {
                    return undefined;
                }
            });
        }
    }
    // ─── Reference Commands ──────────────────────────────────
    registerCommand(context, "luna.browseApi", () => (0, reference_js_1.browseApi)());
    registerCommand(context, "luna.openApiDocs", () => (0, reference_js_1.openApiDocs)());
    registerCommand(context, "luna.openWiki", () => (0, reference_js_1.openWiki)());
    registerCommand(context, "luna.depGraph", () => (0, reference_js_1.depGraph)(context));
    registerCommand(context, "luna.depList", () => (0, reference_js_1.depList)());
    registerCommand(context, "luna.apiCoverage", () => {
        const terminal = vscode.window.createTerminal("Luna API Coverage");
        terminal.show();
        terminal.sendText("python tools/integration_coverage.py");
    });
    // ─── Debug Bridge Commands (Phase 4) ──────────────────────
    (0, debugBridge_js_2.registerDebugBridgeCommands)(context, debugBridge);
    // ─── DAP Lua Debugger ────────────────────────────────────
    (0, luaDebugAdapter_js_1.register)(context);
    // ── luna.debug.runAndConnect — start game then auto-connect ──
    registerCommand(context, "luna.debug.runAndConnect", async () => {
        await (0, run_js_1.runGame)(lunaProcess);
        // Give the engine a moment to boot before trying to connect
        await new Promise((res) => setTimeout(res, 1500));
        const ok = await debugBridge.connect();
        if (ok) {
            vscode.commands.executeCommand("setContext", "luna.debugConnected", true);
            debugBridge.startStatsPolling();
            vscode.window.showInformationMessage("Luna2D started and debug bridge connected.");
        }
        else {
            vscode.window.showWarningMessage("Game launched but debug bridge could not connect. Is debug bridge enabled in conf.lua?");
        }
    });
    // ── luna.debug.performance — live engine stats webview ───────
    registerCommand(context, "luna.debug.performance", () => {
        if (!debugBridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine. Run 'Luna: Debug Connect' first.");
            return;
        }
        const panel = vscode.window.createWebviewPanel("luna.debugPerf", "Luna2D Live Performance", vscode.ViewColumn.Two, { enableScripts: true, retainContextWhenHidden: true });
        panel.webview.html = `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline';">
<style>
  body{font-family:var(--vscode-font-family);color:var(--vscode-foreground);background:var(--vscode-editor-background);padding:16px;margin:0}
  .row{display:flex;gap:24px;margin-bottom:16px;flex-wrap:wrap}
  .metric{background:var(--vscode-editorWidget-background,#1e1e1e);border-radius:6px;padding:12px 20px;min-width:130px;text-align:center}
  .val{font-size:36px;font-weight:700;margin:4px 0;color:var(--vscode-charts-blue,#569cd6)}
  .lbl{font-size:11px;opacity:.6;text-transform:uppercase;letter-spacing:.04em}
  canvas{display:block;width:100%;height:80px;margin-top:6px}
  h2{margin:0 0 12px;font-size:14px}
  .fps-ok{color:#4ec9b0}.fps-warn{color:#dcdcaa}.fps-bad{color:#f44747}
</style></head><body>
<h2>⚡ Live Engine Stats</h2>
<div class="row">
  <div class="metric"><div class="val fps-ok" id="fps">--</div><div class="lbl">FPS</div></div>
  <div class="metric"><div class="val" id="dc">--</div><div class="lbl">Draw Calls</div></div>
  <div class="metric"><div class="val" id="mem">--</div><div class="lbl">Memory MB</div></div>
</div>
<canvas id="fpsChart"></canvas>
<script>
const vscode=acquireVsCodeApi(),hist=[];
function draw(){const c=document.getElementById('fpsChart');if(!c)return;const W=c.offsetWidth||600;c.width=W;c.height=80;const ctx=c.getContext('2d');ctx.clearRect(0,0,W,80);if(hist.length<2)return;const mx=Math.max(...hist,1);ctx.strokeStyle='#4ec9b0';ctx.lineWidth=1.5;ctx.beginPath();hist.forEach((v,i)=>{const x=i/(hist.length-1)*W,y=80-(v/mx)*74-3;i===0?ctx.moveTo(x,y):ctx.lineTo(x,y)});ctx.stroke();ctx.lineTo(W,80);ctx.lineTo(0,80);ctx.closePath();const g=ctx.createLinearGradient(0,0,0,80);g.addColorStop(0,'#4ec9b033');g.addColorStop(1,'#4ec9b000');ctx.fillStyle=g;ctx.fill()}
window.addEventListener('message',e=>{if(e.data.type==='stats'){const{fps,drawCalls,memory}=e.data;document.getElementById('fps').textContent=fps;document.getElementById('fps').className='val '+(fps>=55?'fps-ok':fps>=25?'fps-warn':'fps-bad');document.getElementById('dc').textContent=drawCalls;document.getElementById('mem').textContent=(memory/1024/1024).toFixed(1);hist.push(fps);if(hist.length>120)hist.shift();draw()}});
window.addEventListener('resize',draw);
</script></body></html>`;
        const perfInterval = setInterval(async () => {
            if (!debugBridge.isConnected) {
                clearInterval(perfInterval);
                return;
            }
            try {
                const stats = await debugBridge.getStats();
                panel.webview.postMessage({ type: "stats", ...stats });
            }
            catch { /* ignore */ }
        }, 500);
        panel.onDidDispose(() => clearInterval(perfInterval));
    });
    // ── luna.debug.printHistory — show debug output channel ──────
    registerCommand(context, "luna.debug.printHistory", () => {
        debugBridge.showOutput();
    });
    // ── luna.debug.screenshot — save screenshot from engine ──────
    registerCommand(context, "luna.debug.screenshot", async () => {
        if (!debugBridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine. Run 'Luna: Debug Connect' first.");
            return;
        }
        try {
            const b64 = await debugBridge.takeScreenshot();
            if (!b64) {
                vscode.window.showWarningMessage("Engine did not return screenshot data.");
                return;
            }
            const buf = Buffer.from(b64, "base64");
            const wsFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
            if (!wsFolder) {
                vscode.window.showErrorMessage("No workspace folder.");
                return;
            }
            const ts = new Date().toISOString().replace(/[:.]/g, "-");
            const outPath = require("path").join(wsFolder, `screenshot-${ts}.png`);
            require("fs").writeFileSync(outPath, buf);
            const uri = vscode.Uri.file(outPath);
            await vscode.commands.executeCommand("vscode.open", uri);
            vscode.window.showInformationMessage(`Screenshot saved: screenshot-${ts}.png`);
        }
        catch (err) {
            vscode.window.showErrorMessage(`Screenshot failed: ${err instanceof Error ? err.message : String(err)}`);
        }
    });
    // ── luna.debug.callStack — show current Lua call stack ───────
    registerCommand(context, "luna.debug.callStack", async () => {
        if (!debugBridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine. Run 'Luna: Debug Connect' first.");
            return;
        }
        try {
            const frames = await debugBridge.getCallStack();
            if (frames.length === 0) {
                vscode.window.showInformationMessage("Call stack is empty (game may not be paused).");
                return;
            }
            const items = frames.map((f) => ({
                label: `#${f.level} ${f.name}`,
                description: `${f.source}:${f.line}`,
                detail: `${f.source} line ${f.line}`,
                source: f.source,
                line: f.line,
            }));
            const picked = await vscode.window.showQuickPick(items, {
                title: "Lua Call Stack",
                placeHolder: "Select a frame to navigate to",
            });
            if (picked?.source && picked.source !== "?" && picked.source !== "[C]") {
                const relPath = picked.source.startsWith("@") ? picked.source.slice(1) : picked.source;
                const wsFolder = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
                if (wsFolder) {
                    const filePath = require("path").join(wsFolder, relPath);
                    if (require("fs").existsSync(filePath)) {
                        const doc = await vscode.workspace.openTextDocument(filePath);
                        await vscode.window.showTextDocument(doc, {
                            selection: new vscode.Range(picked.line - 1, 0, picked.line - 1, 0),
                        });
                    }
                }
            }
        }
        catch (err) {
            vscode.window.showErrorMessage(`Call stack failed: ${err instanceof Error ? err.message : String(err)}`);
        }
    });
    // ── luna.debug.status — connection status info ────────────────
    registerCommand(context, "luna.debug.status", async () => {
        const info = debugBridge.getStatusInfo();
        if (!info.connected) {
            const choice = await vscode.window.showInformationMessage(`Luna2D debug bridge: NOT connected (port ${info.port})`, "Connect Now", "Dismiss");
            if (choice === "Connect Now") {
                vscode.commands.executeCommand("luna.debug.connect");
            }
        }
        else {
            try {
                const stats = await debugBridge.getStats();
                vscode.window.showInformationMessage(`Luna2D connected on port ${info.port} · FPS: ${stats.fps} · Draw calls: ${stats.drawCalls} · Memory: ${(stats.memory / 1024 / 1024).toFixed(1)} MB`);
            }
            catch {
                vscode.window.showInformationMessage(`Luna2D debug bridge connected on port ${info.port}.`);
            }
        }
    });
    // ─── CAG Commands ────────────────────────────────────────
    registerCommand(context, "luna.cag.install", () => (0, cag_js_1.installCag)());
    registerCommand(context, "luna.cag.selectAgent", () => (0, cag_js_1.selectAgent)());
    registerCommand(context, "luna.cag.selectSkill", () => (0, cag_js_1.selectSkill)());
    registerCommand(context, "luna.cag.selectPrompt", () => (0, cag_js_1.selectPrompt)());
    registerCommand(context, "luna.cag.update", () => {
        vscode.window.showInformationMessage("CAG update is not yet implemented.");
    });
    // ─── MCP Commands ────────────────────────────────────────
    registerCommand(context, "luna.mcp.install", () => {
        vscode.window.showInformationMessage("MCP server installation is not yet implemented.");
    });
    registerCommand(context, "luna.mcp.status", () => {
        vscode.window.showInformationMessage(mcpProcess ? "MCP server is running." : "MCP server is not running.");
    });
    // ─── Game Jam Commands (Phase 5a) ─────────────────────────
    (0, gameJam_js_1.registerGameJamCommands)(context);
    registerCommand(context, "luna.jam.quickBuild", () => {
        const terminal = vscode.window.createTerminal("Luna Quick Build");
        terminal.show();
        terminal.sendText("cargo build --release");
    });
    registerCommand(context, "luna.jam.checklist", () => {
        vscode.window.showInformationMessage("Submission Checklist is not yet implemented.");
    });
    // ─── Library Commands (Phase 5a) ──────────────────────────
    (0, library_js_1.registerLibraryCommands)(context);
    // ─── Game Dev CAG Commands ────────────────────────────────
    (0, gameDevCag_js_1.registerGameDevCagCommands)(context);
    // ─── Legacy Backward Compat (luna2d.* → luna.*) ─────────
    registerCommand(context, "luna2d.runExample", () => (0, run_js_1.runExample)(lunaProcess));
    registerCommand(context, "luna2d.listExamples", () => (0, run_js_1.runExample)(lunaProcess));
    registerCommand(context, "luna2d.checkBuild", () => {
        const terminal = vscode.window.createTerminal("Luna Build Check");
        terminal.show();
        terminal.sendText("cargo check");
    });
    registerCommand(context, "luna2d.getApiDoc", () => (0, reference_js_1.browseApi)());
    // ─── MCP Server ──────────────────────────────────────────
    const workspaceRoot = getWorkspaceRoot();
    if (workspaceRoot) {
        mcpProcess = (0, server_js_1.startMcpServer)(workspaceRoot);
    }
    // ─── Lua Language Server Integration ──────────────────
    configureLuaWorkspaceLibrary(context);
    // ─── Settings Change Listener ──────────────────────────
    context.subscriptions.push(vscode.workspace.onDidChangeConfiguration((e) => {
        if (e.affectsConfiguration("luna.luaVersion")) {
            apiData.load(context.extensionPath).catch((err) => {
                console.error("Failed to reload Luna API data:", err);
            });
            configureLuaWorkspaceLibrary(context);
        }
    }));
    // ─── Context Keys ───────────────────────────────────────
    vscode.commands.executeCommand("setContext", "luna.gameRunning", false);
}
/**
 * Deactivates the extension.
 */
function deactivate() {
    if (mcpProcess) {
        mcpProcess.kill();
        mcpProcess = undefined;
    }
}
/** Helper to register a command and push to subscriptions. */
function registerCommand(context, id, handler) {
    context.subscriptions.push(vscode.commands.registerCommand(id, handler));
}
function getWorkspaceRoot() {
    return vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
}
/**
 * Configures lua-language-server (sumneko.lua) to include the luna2d LuaCATS
 * type definitions and sets the Lua runtime version to match luna.luaVersion.
 */
function configureLuaWorkspaceLibrary(context) {
    const annotationsDir = path.join(context.extensionPath, "data");
    const luaConfig = vscode.workspace.getConfiguration("Lua");
    // Add the annotations data/ folder to Lua.workspace.library
    const currentLibrary = luaConfig.get("workspace.library") ?? [];
    if (!currentLibrary.includes(annotationsDir)) {
        const updated = [...currentLibrary, annotationsDir];
        luaConfig
            .update("workspace.library", updated, vscode.ConfigurationTarget.Global)
            .then(undefined, () => { });
    }
    // Sync Lua.runtime.version to luna.luaVersion
    const lunaVersion = vscode.workspace
        .getConfiguration("luna")
        .get("luaVersion", "luajit");
    const runtimeVersion = lunaVersion === "lua54" ? "Lua 5.4" : "LuaJIT";
    luaConfig
        .update("runtime.version", runtimeVersion, vscode.ConfigurationTarget.Global)
        .then(undefined, () => { });
}
//# sourceMappingURL=extension2.js.map