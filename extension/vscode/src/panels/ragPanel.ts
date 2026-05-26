import * as vscode from "vscode";
import { execRagQuery } from "../services/rag.js";

export class RagPanel {
  public static currentPanel: RagPanel | undefined;
  private readonly _panel: vscode.WebviewPanel;
  private _disposables: vscode.Disposable[] = [];
  private readonly workspaceRoot: string;

  private constructor(panel: vscode.WebviewPanel, workspaceRoot: string) {
    this._panel = panel;
    this.workspaceRoot = workspaceRoot;

    this._update();
    this._panel.onDidDispose(() => this.dispose(), null, this._disposables);

    this._panel.webview.onDidReceiveMessage(
      async (message) => {
        switch (message.command) {
          case "search":
            await this.handleSearch(message.query, message.profile);
            return;
          case "openFile":
            const uri = vscode.Uri.file(`${this.workspaceRoot}/${message.path}`);
            vscode.commands.executeCommand("vscode.open", uri);
            return;
        }
      },
      null,
      this._disposables
    );
  }

  public static createOrShow(workspaceRoot: string) {
    const column = vscode.window.activeTextEditor
      ? vscode.window.activeTextEditor.viewColumn
      : undefined;

    if (RagPanel.currentPanel) {
      RagPanel.currentPanel._panel.reveal(column);
      return;
    }

    const panel = vscode.window.createWebviewPanel(
      "lurek2dRag",
      "Lurek2D RAG Search",
      column || vscode.ViewColumn.One,
      {
        enableScripts: true,
        retainContextWhenHidden: true,
      }
    );

    RagPanel.currentPanel = new RagPanel(panel, workspaceRoot);
  }

  private async handleSearch(query: string, profile: "all" | "game" | "engine") {
    try {
      this._panel.webview.postMessage({ command: "loading" });
      const rawOutput = await execRagQuery(this.workspaceRoot, query, profile);
      const data = JSON.parse(rawOutput);
      
      if (data.error) {
        this._panel.webview.postMessage({ command: "error", error: data.error });
      } else {
        this._panel.webview.postMessage({ command: "results", results: data.results });
      }
    } catch (e: any) {
      this._panel.webview.postMessage({ command: "error", error: e.toString() });
    }
  }

  private _update() {
    this._panel.webview.html = this._getHtmlForWebview();
  }

  public dispose() {
    RagPanel.currentPanel = undefined;
    this._panel.dispose();
    while (this._disposables.length) {
      const x = this._disposables.pop();
      if (x) {
        x.dispose();
      }
    }
  }

  private _getHtmlForWebview() {
    return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <style>
    body { font-family: var(--vscode-font-family); padding: 20px; color: var(--vscode-foreground); }
    .search-container { display: flex; gap: 10px; margin-bottom: 20px; }
    input { flex: 1; padding: 8px; background: var(--vscode-input-background); color: var(--vscode-input-foreground); border: 1px solid var(--vscode-input-border); }
    select, button { padding: 8px; background: var(--vscode-button-background); color: var(--vscode-button-foreground); border: none; cursor: pointer; }
    button:hover { background: var(--vscode-button-hoverBackground); }
    .result { margin-bottom: 20px; border: 1px solid var(--vscode-panel-border); padding: 10px; border-radius: 4px; }
    .result-title { font-weight: bold; margin-bottom: 5px; color: var(--vscode-textLink-foreground); cursor: pointer; }
    .result-path { font-size: 0.8em; opacity: 0.8; margin-bottom: 10px; }
    pre { background: var(--vscode-textCodeBlock-background); padding: 10px; overflow-x: auto; font-family: monospace; }
  </style>
</head>
<body>
  <h2>Lurek2D RAG Search</h2>
  <div class="search-container">
    <input type="text" id="query" placeholder="Enter search keywords..." autofocus />
    <select id="profile">
      <option value="all">Profile: All</option>
      <option value="game">Profile: Game Dev</option>
      <option value="engine">Profile: Engine Dev</option>
    </select>
    <button id="search-btn">Search</button>
  </div>
  <div id="status"></div>
  <div id="results"></div>

  <script>
    const vscode = acquireVsCodeApi();
    const queryInput = document.getElementById('query');
    const profileSelect = document.getElementById('profile');
    const searchBtn = document.getElementById('search-btn');
    const statusDiv = document.getElementById('status');
    const resultsDiv = document.getElementById('results');

    function performSearch() {
      const query = queryInput.value.trim();
      if (!query) return;
      vscode.postMessage({ command: 'search', query, profile: profileSelect.value });
    }

    searchBtn.addEventListener('click', performSearch);
    queryInput.addEventListener('keypress', (e) => { if (e.key === 'Enter') performSearch(); });

    window.addEventListener('message', event => {
      const message = event.data;
      switch (message.command) {
        case 'loading':
          statusDiv.innerText = 'Searching...';
          resultsDiv.innerHTML = '';
          break;
        case 'error':
          statusDiv.innerText = 'Error: ' + message.error;
          break;
        case 'results':
          statusDiv.innerText = message.results.length + ' results found.';
          resultsDiv.innerHTML = message.results.map(r => \`
            <div class="result">
              <div class="result-title" onclick="vscode.postMessage({command: 'openFile', path: '\${r.path}'})">
                \${r.title} <span style="font-size: 0.8em; background: var(--vscode-badge-background); color: var(--vscode-badge-foreground); padding: 2px 5px; border-radius: 10px;">\${r.type}</span>
              </div>
              <div class="result-path">\${r.path}</div>
              <pre>\${r.context.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\\[\\[/g, '<mark>').replace(/\\]\\]/g, '</mark>')}</pre>
            </div>
          \`).join('');
          break;
      }
    });
  </script>
</body>
</html>`;
  }
}
