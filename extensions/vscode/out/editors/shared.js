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
exports.WebviewEditor = void 0;
exports.getNonce = getNonce;
exports.getSharedCss = getSharedCss;
exports.wrapHtml = wrapHtml;
const vscode = __importStar(require("vscode"));
/**
 * Generates a cryptographically random nonce for CSP.
 */
function getNonce() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let result = "";
    for (let i = 0; i < 32; i++) {
        result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
}
/**
 * Shared CSS theme for all Luna editors.
 */
function getSharedCss() {
    return `
    :root {
      --bg: #1e1e1e; --surface: #252526; --surface-2: #2d2d2d;
      --border: #3c3c3c; --text: #cccccc; --text-dim: #858585;
      --accent: #007acc; --accent-2: #4ec9b0;
      --success: #4caf50; --warning: #ff9800; --danger: #f44336;
      --selection: #264f78;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      color: var(--text); background: var(--bg);
      overflow: hidden; height: 100vh;
    }
    button {
      background: var(--surface-2); color: var(--text); border: 1px solid var(--border);
      padding: 4px 12px; border-radius: 3px; cursor: pointer; font-size: 12px;
    }
    button:hover { background: var(--accent); border-color: var(--accent); }
    button.active { background: var(--accent); border-color: var(--accent); }
    button.danger { border-color: var(--danger); }
    button.danger:hover { background: var(--danger); }
    input, select, textarea {
      background: var(--surface); color: var(--text); border: 1px solid var(--border);
      padding: 3px 6px; border-radius: 3px; font-size: 12px;
    }
    input:focus, select:focus, textarea:focus { outline: none; border-color: var(--accent); }
    label { font-size: 12px; color: var(--text-dim); }
    .toolbar {
      display: flex; align-items: center; gap: 6px; padding: 6px 10px;
      background: var(--surface); border-bottom: 1px solid var(--border);
    }
    .toolbar .sep { width: 1px; height: 20px; background: var(--border); }
    .panel {
      background: var(--surface); border-right: 1px solid var(--border);
      overflow-y: auto; padding: 8px;
    }
    .panel h3 {
      font-size: 11px; text-transform: uppercase; color: var(--text-dim);
      margin-bottom: 6px; letter-spacing: 0.5px;
    }
    .status-bar {
      display: flex; align-items: center; gap: 12px; padding: 2px 10px;
      background: var(--surface); border-top: 1px solid var(--border);
      font-size: 11px; color: var(--text-dim);
    }
    .list-item {
      padding: 4px 8px; cursor: pointer; border-radius: 3px; font-size: 12px;
    }
    .list-item:hover { background: var(--surface-2); }
    .list-item.selected { background: var(--selection); }
    .section { margin-bottom: 12px; }
    .field { display: flex; flex-direction: column; gap: 2px; margin-bottom: 6px; }
    .field-row { display: flex; align-items: center; gap: 6px; margin-bottom: 4px; }
    canvas { display: block; }
  `;
}
/**
 * Wraps body + scripts into a complete CSP-safe HTML document.
 */
function wrapHtml(nonce, title, extraCss, body, scripts) {
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy"
    content="default-src 'none'; style-src 'nonce-${nonce}'; script-src 'nonce-${nonce}'; img-src data:;">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <style nonce="${nonce}">${getSharedCss()}${extraCss}</style>
</head>
<body>
${body}
<script nonce="${nonce}">
const vscode = acquireVsCodeApi();
${scripts}
</script>
</body>
</html>`;
}
/**
 * Abstract base class for all Luna webview editors.
 */
class WebviewEditor {
    context;
    data;
    panel;
    isDirty = false;
    disposables = [];
    constructor(context, viewType, title, data = {}) {
        this.context = context;
        this.data = data;
        this.panel = vscode.window.createWebviewPanel(viewType, title, vscode.ViewColumn.One, { enableScripts: true, retainContextWhenHidden: true });
        this.panel.webview.onDidReceiveMessage((msg) => this.handleMessage(msg), undefined, this.disposables);
        this.panel.onDidDispose(() => this.dispose(), undefined, this.disposables);
        this.panel.webview.html = this.getHtml();
    }
    async exportFile(content, defaultName, filterLabel, ext) {
        const uri = await vscode.window.showSaveDialog({
            defaultUri: vscode.Uri.file(defaultName),
            filters: { [filterLabel]: [ext] },
        });
        if (uri) {
            await vscode.workspace.fs.writeFile(uri, Buffer.from(content, "utf-8"));
            vscode.window.showInformationMessage(`Exported to ${uri.fsPath}`);
        }
    }
    async exportLua(content, defaultName) {
        return this.exportFile(content, defaultName, "Lua", "lua");
    }
    async exportToml(content, defaultName) {
        return this.exportFile(content, defaultName, "TOML", "toml");
    }
    dispose() {
        for (const d of this.disposables) {
            d.dispose();
        }
    }
}
exports.WebviewEditor = WebviewEditor;
//# sourceMappingURL=shared.js.map