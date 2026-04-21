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
exports.openApiUsageReport = openApiUsageReport;
exports.quickInsertLunaApi = quickInsertLunaApi;
const vscode = __importStar(require("vscode"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
async function scanApiUsage() {
    const luaFiles = await vscode.workspace.findFiles("**/*.lua", "**/node_modules/**");
    const usage = new Map();
    for (const uri of luaFiles) {
        let text;
        try {
            text = fs.readFileSync(uri.fsPath, "utf8");
        }
        catch {
            continue;
        }
        const relFile = vscode.workspace.asRelativePath(uri);
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line.trimStart().startsWith("--"))
                continue;
            // Match lurek.module.function( calls
            const re = /lurek\.(\w+)\.(\w+)\s*\(/g;
            let m;
            while ((m = re.exec(line)) !== null) {
                const key = `lurek.${m[1]}.${m[2]}`;
                if (!usage.has(key)) {
                    usage.set(key, { func: key, count: 0, files: new Set(), lines: [] });
                }
                const entry = usage.get(key);
                entry.count++;
                entry.files.add(relFile);
                if (entry.lines.length < 5) {
                    entry.lines.push({ file: relFile, line: i + 1, text: line.trim() });
                }
            }
        }
    }
    return Array.from(usage.values()).sort((a, b) => b.count - a.count);
}
// ── Report panel ──────────────────────────────────────────────
let _panel;
async function openApiUsageReport(context) {
    if (_panel) {
        _panel.reveal(vscode.ViewColumn.Two);
        await refreshPanel();
        return;
    }
    _panel = vscode.window.createWebviewPanel("lurek.apiUsage", "Luna2D API Usage", vscode.ViewColumn.Two, { enableScripts: true, retainContextWhenHidden: true });
    _panel.onDidDispose(() => { _panel = undefined; }, null, context.subscriptions);
    _panel.webview.onDidReceiveMessage(async (msg) => {
        if (msg.type === "refresh")
            await refreshPanel();
        if (msg.type === "open") {
            const uri = vscode.Uri.file(path.join(vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? "", msg.file));
            await vscode.window.showTextDocument(uri, {
                selection: new vscode.Range(msg.line - 1, 0, msg.line - 1, 0),
            });
        }
    }, null, context.subscriptions);
    await refreshPanel();
}
async function refreshPanel() {
    if (!_panel)
        return;
    _panel.webview.postMessage({ type: "loading" });
    const usages = await scanApiUsage();
    _panel.webview.html = buildHtml(usages);
}
function buildHtml(usages) {
    const totalCalls = usages.reduce((s, u) => s + u.count, 0);
    const uniqueFuncs = usages.length;
    const top10 = usages.slice(0, 10);
    // Group by module
    const byModule = new Map();
    for (const u of usages) {
        const mod = u.func.split(".")[1] ?? "?";
        if (!byModule.has(mod))
            byModule.set(mod, []);
        byModule.get(mod).push(u);
    }
    const moduleRows = Array.from(byModule.entries())
        .sort((a, b) => b[1].reduce((s, u) => s + u.count, 0) - a[1].reduce((s, u) => s + u.count, 0))
        .map(([mod, fns]) => {
        const total = fns.reduce((s, u) => s + u.count, 0);
        return `<tr><td><code>lurek.${esc(mod)}</code></td><td>${fns.length}</td><td>${total}</td></tr>`;
    }).join("");
    const topRows = top10.map(u => {
        const lineLinks = u.lines.map(l => `<a href="#" data-file="${esc(l.file)}" data-line="${l.line}" class="loc">${esc(l.file)}:${l.line}</a>`).join(", ");
        return `<tr>
      <td><code>${esc(u.func)}</code></td>
      <td>${u.count}</td>
      <td>${u.files.size}</td>
      <td style="font-size:11px;opacity:.7">${lineLinks}</td>
    </tr>`;
    }).join("");
    const unusedRows = usages.filter(u => u.count === 0).map(u => `<tr><td><code>${esc(u.func)}</code></td></tr>`).join("");
    return /* html */ `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline';">
<style>
  body { font-family: var(--vscode-font-family); color: var(--vscode-foreground); background: var(--vscode-editor-background); padding: 12px; margin: 0; }
  h2 { margin: 0 0 10px; font-size: 14px; }
  h3 { font-size: 12px; text-transform: uppercase; letter-spacing: .05em; opacity: 0.6; margin: 16px 0 6px; }
  .stats { display: flex; gap: 20px; margin-bottom: 16px; flex-wrap: wrap; }
  .stat { background: var(--vscode-editorWidget-background); border-radius: 4px; padding: 8px 16px; text-align: center; }
  .stat-val { font-size: 24px; font-weight: 700; color: var(--vscode-charts-blue, #569cd6); }
  .stat-lbl { font-size: 11px; opacity: 0.7; }
  table { width: 100%; border-collapse: collapse; font-size: 13px; margin-bottom: 16px; }
  th { text-align: left; padding: 4px 8px; border-bottom: 1px solid var(--vscode-panel-border); font-size: 11px; opacity: 0.6; }
  td { padding: 4px 8px; border-bottom: 1px solid var(--vscode-panel-border, rgba(255,255,255,0.05)); }
  code { font-family: var(--vscode-editor-font-family); color: #9cdcfe; }
  a.loc { color: var(--vscode-textLink-foreground); text-decoration: none; font-family: var(--vscode-editor-font-family); font-size: 11px; }
  a.loc:hover { text-decoration: underline; }
  button { background: var(--vscode-button-background); color: var(--vscode-button-foreground); border: none; padding: 4px 10px; border-radius: 3px; cursor: pointer; font-size: 12px; margin-bottom: 10px; }
</style>
</head>
<body>
<h2>📊 Luna2D API Usage Report</h2>
<button onclick="vscode.postMessage({type:'refresh'})">⟳ Re-scan</button>

<div class="stats">
  <div class="stat"><div class="stat-val">${totalCalls}</div><div class="stat-lbl">Total Calls</div></div>
  <div class="stat"><div class="stat-val">${uniqueFuncs}</div><div class="stat-lbl">Unique Functions</div></div>
  <div class="stat"><div class="stat-val">${byModule.size}</div><div class="stat-lbl">Modules Used</div></div>
</div>

<h3>By Module</h3>
<table>
  <thead><tr><th>Module</th><th>Functions</th><th>Total Calls</th></tr></thead>
  <tbody>${moduleRows}</tbody>
</table>

<h3>Top 10 Most Called</h3>
<table>
  <thead><tr><th>Function</th><th>Calls</th><th>Files</th><th>Locations</th></tr></thead>
  <tbody>${topRows}</tbody>
</table>

${unusedRows ? `<h3>Called 0 times</h3><table><thead><tr><th>Function</th></tr></thead><tbody>${unusedRows}</tbody></table>` : ""}

<script>
const vscode = acquireVsCodeApi();
document.querySelectorAll('a.loc').forEach(a => {
  a.addEventListener('click', e => {
    e.preventDefault();
    vscode.postMessage({ type: 'open', file: a.dataset.file, line: parseInt(a.dataset.line) });
  });
});
</script>
</body>
</html>`;
}
function esc(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}
// ── Quick-insert Luna API function ────────────────────────────
async function quickInsertLunaApi(apiData) {
    const editor = vscode.window.activeTextEditor;
    if (!editor) {
        vscode.window.showWarningMessage("Open a Lua file first.");
        return;
    }
    const funcs = apiData.getAllFunctions();
    const items = funcs
        .filter(f => f.fullPath.startsWith("lurek."))
        .map(f => ({
        label: f.fullPath,
        description: f.description ?? "",
        detail: f.parameters?.map(p => `${p.name}: ${p.type}`).join(", "),
    }));
    const picked = await vscode.window.showQuickPick(items, {
        placeHolder: "Search lurek.* function to insert…",
        matchOnDescription: true,
        matchOnDetail: true,
    });
    if (!picked)
        return;
    const func = funcs.find(f => f.fullPath === picked.label);
    if (!func)
        return;
    // Build call snippet with $1 … $N placeholders for each parameter
    let snippet = func.fullPath + "(";
    if (func.parameters?.length) {
        const args = func.parameters
            .filter(p => !p.optional)
            .map((p, i) => `\${${i + 1}:${p.name}}`)
            .join(", ");
        snippet += args;
    }
    snippet += ")$0";
    editor.insertSnippet(new vscode.SnippetString(snippet));
}
//# sourceMappingURL=apiUsage.js.map