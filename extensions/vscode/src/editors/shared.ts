import * as vscode from "vscode";

// ─── Nonce ────────────────────────────────────────────────────────────────────

export function getNonce(): string {
  const chars =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  let result = "";
  for (let i = 0; i < 32; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

// ─── SVG Icon Set ─────────────────────────────────────────────────────────────

export const ICONS = {
  // toolbar actions
  save: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M13.354 1.146l1.5 1.5A.5.5 0 0115 3v11a1 1 0 01-1 1H2a1 1 0 01-1-1V2a1 1 0 011-1h10.5a.5.5 0 01.354.146zM4 2H2v12h1V9.5A.5.5 0 013.5 9h9a.5.5 0 01.5.5V14h1V3.207l-1-1V5.5A.5.5 0 0112.5 6h-7A.5.5 0 015 5.5V2H4zm9 12v-4H4v4h9zM6 2v3h6V2H6z"/></svg>',
  undo: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M5.5 7H2v3h1V8.414l1.243 1.243a5.5 5.5 0 117.514 0l-.707-.707a4.5 4.5 0 10-6.172 0L6.5 10.414V7h-1z"/></svg>',
  redo: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M10.5 7H14v3h-1V8.414l-1.243 1.243a5.5 5.5 0 11-7.514 0l.707-.707a4.5 4.5 0 106.172 0L9.5 10.414V7h1z"/></svg>',
  exportFile: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 1l4 4h-3v5H7V5H4l4-4zM2 12h12v2H2v-2z"/></svg>',
  importFile: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 10L4 6h3V1h2v5h3l-4 4zM2 12h12v2H2v-2z"/></svg>',
  copy: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M4 4h8v10H4V4zm1 1v8h6V5H5zM2 2h8v1H3v9H2V2z"/></svg>',
  insert: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M7 2h2v5h5v2H9v5H7V9H2V7h5V2z"/></svg>',
  play: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M4 2l10 6-10 6V2z"/></svg>',
  stop: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><rect x="3" y="3" width="10" height="10" rx="1"/></svg>',
  refresh: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M13 3a7 7 0 00-10.95 1.7L3.5 6H1v-2.5l1.12 1.12A8 8 0 0114 3.07V3zM3 13a7 7 0 0010.95-1.7L12.5 10H15v2.5l-1.12-1.12A8 8 0 012 12.93V13z"/></svg>',
  trash: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M5.5 1h5l.5.5V3h4v1h-1v10l-.5.5h-11L2 14V4H1V3h4V1.5l.5-.5zM6 2v1h4V2H6zM3 4v10h10V4H3zm2 2h1v7H5V6zm3 0h1v7H8V6zm3 0h1v7h-1V6z"/></svg>',
  zoomIn: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M7 1a6 6 0 014.472 10.058l3.235 3.235-.707.707-3.235-3.235A6 6 0 117 1zm0 1a5 5 0 100 10A5 5 0 007 2zm.5 2v2.5H10v1H7.5V10h-1V7.5H4v-1h2.5V4h1z"/></svg>',
  zoomOut: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M7 1a6 6 0 014.472 10.058l3.235 3.235-.707.707-3.235-3.235A6 6 0 117 1zm0 1a5 5 0 100 10A5 5 0 007 2zm3 4v1H4v-1h6z"/></svg>',
  settings: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M9.1 2L9 1H7l-.1 1-.9.4-.7-.7-1.4 1.4.7.7-.4.9-1 .1V6l1 .1.4.9-.7.7 1.4 1.4.7-.7.9.4.1 1h2l.1-1 .9-.4.7.7 1.4-1.4-.7-.7.4-.9 1-.1V4l-1-.1-.4-.9.7-.7-1.4-1.4-.7.7-.9-.4zM8 6a2 2 0 110 4 2 2 0 010-4z"/></svg>',
  grid: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M1 1h4v4H1V1zm5 0h4v4H6V1zm5 0h4v4h-4V1zM1 6h4v4H1V6zm5 0h4v4H6V6zm5 0h4v4h-4V6zM1 11h4v4H1v-4zm5 0h4v4H6v-4zm5 0h4v4h-4v-4z"/></svg>',
  eye: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 3C4.36 3 1.26 5.28 0 8.5c1.26 3.22 4.36 5.5 8 5.5s6.74-2.28 8-5.5C14.74 5.28 11.64 3 8 3zm0 9a3.5 3.5 0 110-7 3.5 3.5 0 010 7zm0-5.5a2 2 0 100 4 2 2 0 000-4z"/></svg>',
  eyeOff: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M1.5 1.1l13.4 13.4-.7.7L.8 1.8l.7-.7zM8 3c3.64 0 6.74 2.28 8 5.5a9.77 9.77 0 01-2.43 3.53l-.71-.71A8.77 8.77 0 0015 8.5C13.82 5.7 11.11 4 8 4c-.82 0-1.62.12-2.37.34l-.8-.8C5.7 3.19 6.83 3 8 3zM1 8.5C2.18 11.3 4.89 13 8 13c.82 0 1.62-.12 2.37-.34l.8.8C10.3 13.81 9.17 14 8 14c-3.64 0-6.74-2.28-8-5.5.44-1.13 1.08-2.14 1.87-2.97l.71.71A8.77 8.77 0 001 8.5z"/></svg>',
  lock: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M4 7V5a4 4 0 118 0v2h1v7H3V7h1zm1-2a3 3 0 116 0v2H5V5zm-1 3v5h8V8H4z"/></svg>',
  unlock: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M11 1a4 4 0 00-4 4v2H3v7h10V7H8V5a3 3 0 016 0v1h1V5a4 4 0 00-4-4zM4 8h8v5H4V8z"/></svg>',
  add: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M7 2h2v5h5v2H9v5H7V9H2V7h5V2z"/></svg>',
  remove: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M2 7h12v2H2V7z"/></svg>',
  moveUp: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 3l5 5h-3v5H6V8H3l5-5z"/></svg>',
  moveDown: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 13l-5-5h3V3h4v5h3l-5 5z"/></svg>',
  // tool icons
  pen: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M13.23.71a1 1 0 00-1.41 0L10 2.54l3 3 1.83-1.83a1 1 0 000-1.41l-1.6-1.6zM9.13 3.4L2 10.54V13.5h2.96l7.13-7.14-3-2.96z"/></svg>',
  eraser: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8.09 2L14 7.91l-5.5 5.5-1.5.59H2v-1l.59-1.5L8.09 2zM3.5 13h3.09l5-5L8.5 4.91l-5 5V13z"/></svg>',
  bucket: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M6 1l7 7-4.5 4.5L2 6l4-5zm.5 1.71L3.71 6 9 11.29l3.29-3.29L6.5 2.71zM12 10s2 2.5 2 3.5a2 2 0 01-4 0c0-1 2-3.5 2-3.5z"/></svg>',
  rect: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M1 3h14v10H1V3zm1 1v8h12V4H2z"/></svg>',
  line: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M13.5 2.5l.7.7-11.3 11.3-.7-.7L13.5 2.5z"/></svg>',
  select: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M2 2h4v1H3v3H2V2zm8 0h4v4h-1V3h-3V2zM2 10h1v3h3v1H2v-4zm11 0h1v4h-4v-1h3v-3z" opacity=".7"/><rect x="1" y="1" width="14" height="14" fill="none" stroke="currentColor" stroke-dasharray="2 2"/></svg>',
  pick: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M7 1a6 6 0 014.47 10.06l3.24 3.23-.71.71-3.23-3.24A6 6 0 117 1zm0 1a5 5 0 100 10A5 5 0 007 2z"/></svg>',
  hand: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M8 1a2 2 0 012 2v3a2 2 0 012 2v1a2 2 0 012 2v1c0 2.21-1.79 4-4 4H8c-2.21 0-4-1.79-4-4V5a2 2 0 014 0V3a2 2 0 012-2zm1 2a1 1 0 10-2 0v5h-1V5a1 1 0 10-2 0v7c0 1.66 1.34 3 3 3h2c1.66 0 3-1.34 3-3v-1a1 1 0 10-2 0v-1h-1V8a1 1 0 10-2 0V6h-1V3a1 1 0 011-1z"/></svg>',
  stamp: '<svg width="16" height="16" viewBox="0 0 16 16" fill="currentColor"><path d="M6 1h4v4h2l-1 4H5L4 5h2V1zm-4 10h12v1H2v-1zm0 3h12v1H2v-1z"/></svg>',
  // status
  dirty: '<svg width="10" height="10" viewBox="0 0 10 10"><circle cx="5" cy="5" r="4" fill="#e2b340"/></svg>',
  clean: '<svg width="10" height="10" viewBox="0 0 10 10"><circle cx="5" cy="5" r="4" fill="#4caf50"/></svg>',
} as const;

// ─── Shared CSS — Game-Editor Design System ───────────────────────────────────

export function getSharedCss(): string {
  return `
    /* ── Reset & Theme (VS Code Native) ─────────────────── */
    :root {
      --bg: var(--vscode-editor-background);
      --surface: var(--vscode-sideBar-background);
      --surface-2: var(--vscode-editorGroupHeader-tabsBackground);
      --surface-3: var(--vscode-sideBarSectionHeader-background);
      --border: var(--vscode-panel-border);
      --text: var(--vscode-editor-foreground);
      --text-dim: var(--vscode-descriptionForeground);
      --text-bright: var(--vscode-foreground);
      --accent: var(--vscode-focusBorder);
      --accent-dim: color-mix(in srgb, var(--vscode-focusBorder) 20%, transparent);
      --selection: var(--vscode-list-activeSelectionBackground);
      --hover: var(--vscode-list-hoverBackground);
      
      --btn-bg: var(--vscode-button-background);
      --btn-fg: var(--vscode-button-foreground);
      --btn-hover: var(--vscode-button-hoverBackground);
      --btn-secondary-bg: var(--vscode-button-secondaryBackground, var(--vscode-editorWidget-background));
      --btn-secondary-fg: var(--vscode-button-secondaryForeground, var(--vscode-editorWidget-foreground));
      --btn-secondary-hover: var(--vscode-button-secondaryHoverBackground, var(--vscode-list-hoverBackground));

      --input-bg: var(--vscode-input-background);
      --input-fg: var(--vscode-input-foreground);
      --input-border: var(--vscode-input-border);
      
      --toolbar-bg: var(--vscode-editorGroupHeader-tabsBackground);
      --activity-bg: var(--vscode-activityBar-background);
      --activity-fg: var(--vscode-activityBar-foreground);
      --activity-fg-inactive: var(--vscode-activityBar-inactiveForeground);
      --activity-active-border: var(--vscode-activityBar-activeBorder, var(--vscode-focusBorder));

      --radius: 2px;
      --radius-lg: 4px;
      --font-mono: var(--vscode-editor-font-family, 'Cascadia Code', 'Consolas', monospace);
      --font-ui: var(--vscode-font-family, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif);
      --z-toolbar: 100;
      --z-dropdown: 200;
      --z-modal: 300;
      --z-toast: 400;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: var(--font-ui);
      font-size: 13px;
      color: var(--text);
      background: var(--bg);
      overflow: hidden; height: 100vh;
      -webkit-font-smoothing: antialiased;
    }

    /* ── Typography ─────────────────────────────────────── */
    h1 { font-size: 14px; font-weight: 600; color: var(--text-bright); }
    h2 { font-size: 13px; font-weight: 600; color: var(--text); }
    h3 { font-size: 11px; font-weight: 600; text-transform: uppercase; color: var(--text-dim); }
    code, .mono { font-family: var(--font-mono); font-size: 12px; }

    /* ── Buttons ────────────────────────────────────────── */
    button, .btn {
      display: inline-flex; align-items: center; justify-content: center; gap: 4px;
      background: var(--btn-secondary-bg); color: var(--btn-secondary-fg); 
      border: 1px solid var(--border);
      padding: 4px 8px; border-radius: var(--radius); cursor: pointer; font-size: 12px;
      font-family: var(--font-ui); user-select: none; white-space: nowrap;
    }
    button:hover { background: var(--btn-secondary-hover); }
    button:focus-visible { outline: 1px solid var(--accent); outline-offset: -1px; }
    button:disabled { opacity: 0.4; cursor: not-allowed; pointer-events: none; }
    button.primary { background: var(--btn-bg); border-color: var(--btn-bg); color: var(--btn-fg); }
    button.primary:hover { background: var(--btn-hover); }
    button.ghost { background: transparent; border-color: transparent; }
    button.ghost:hover { background: var(--hover); }
    button svg { width: 14px; height: 14px; flex-shrink: 0; }

    /* ── Icon Button (VS Code Toolbar style) ────────────── */
    .icon-btn {
      width: 28px; height: 28px; padding: 0; display: flex;
      align-items: center; justify-content: center;
      background: transparent; border: 1px solid transparent;
      border-radius: var(--radius); cursor: pointer; color: var(--text-dim);
    }
    .icon-btn:hover { background: var(--hover); color: var(--text-bright); }
    .icon-btn.active, .icon-btn[aria-pressed="true"] {
      background: var(--selection); color: var(--text-bright); border-color: transparent;
    }
    .icon-btn:focus-visible { outline: 1px solid var(--accent); outline-offset: -1px; }
    .icon-btn.help-btn { font-size: 13px; font-weight: 700; }
    .icon-btn svg { width: 16px; height: 16px; }

    /* ── Form Controls (VS Code style) ──────────────────── */
    input, select, textarea {
      background: var(--input-bg); color: var(--input-fg); border: 1px solid var(--input-border);
      padding: 4px 6px; border-radius: var(--radius); font-size: 13px;
      font-family: var(--font-ui);
    }
    input:focus, select:focus, textarea:focus {
      outline: 1px solid var(--accent); outline-offset: -1px; border-color: transparent;
    }
    input[type="range"] {
      -webkit-appearance: none; height: 2px; background: var(--border);
      border-radius: 0; border: none; padding: 0;
    }
    input[type="range"]::-webkit-slider-thumb {
      -webkit-appearance: none; width: 12px; height: 12px;
      background: var(--accent); border-radius: 50%; cursor: pointer;
    }
    input[type="checkbox"] {
      appearance: none; width: 16px; height: 16px; border: 1px solid var(--vscode-checkbox-border, var(--input-border));
      border-radius: 3px; background: var(--vscode-checkbox-background, var(--input-bg)); cursor: pointer;
      display: inline-flex; align-items: center; justify-content: center; padding: 0; vertical-align: middle;
    }
    input[type="checkbox"]:checked {
      background: var(--vscode-checkbox-background, var(--input-bg)); border-color: var(--accent);
    }
    input[type="checkbox"]:checked::after {
      content: ''; display: block; width: 8px; height: 4px;
      border-left: 2px solid var(--vscode-checkbox-foreground, var(--input-fg)); 
      border-bottom: 2px solid var(--vscode-checkbox-foreground, var(--input-fg));
      transform: rotate(-45deg) translateY(-2px);
    }
    input[type="number"] { width: 60px; }
    select { padding-right: 20px; cursor: pointer; background: var(--vscode-dropdown-background); color: var(--vscode-dropdown-foreground); border: 1px solid var(--vscode-dropdown-border); }
    label { font-size: 12px; color: var(--text); user-select: none; display: inline-flex; align-items: center; gap: 4px; }
    textarea { font-family: var(--font-mono); resize: vertical; }

    /* ── Toolbar (Top - VS Code Editor Title style) ─────── */
    .toolbar {
      display: flex; align-items: center; gap: 4px; padding: 4px 8px;
      background: var(--toolbar-bg);
      border-bottom: 1px solid var(--border);
      z-index: var(--z-toolbar); flex-shrink: 0; min-height: 35px;
      flex-wrap: wrap; position: sticky; top: 0;
    }
    .toolbar .group {
      display: flex; align-items: center; gap: 2px;
      padding: 0; background: transparent; border: none; min-height: 28px;
    }
    .toolbar .sep {
      width: 1px; height: 16px; background: var(--border); margin: 0 4px; flex-shrink: 0;
    }
    .toolbar .spacer { flex: 1; }
    .toolbar label { margin: 0 4px; }

    /* ── Tool Sidebar (Left - VS Code Activity Bar style) ── */
    .tool-rail, .auto-tool-rail { grid-column: 1; grid-row: 2; z-index: 10; }
    .auto-tool-rail {
      position: fixed; left: 0; top: 36px; bottom: 22px; z-index: calc(var(--z-toolbar) + 1);
    }
    .tool-rail .tool-group {
      display: flex; flex-direction: column; gap: 4px; width: 100%; align-items: center;
    }
    .tool-rail .tool-group + .tool-group {
      padding-top: 8px; margin-top: 4px; position: relative;
    }
    .tool-rail .tool-group + .tool-group::before {
      content: ''; position: absolute; top: 0; width: 30px; height: 1px; background: var(--border); left: 9px;
    }
    .auto-tool-rail .tool-rail-sep {
      width: 30px; height: 1px; background: var(--border); margin: 4px 0;
    }
    .tool-rail .icon-btn, .auto-tool-rail .icon-btn {
      width: 48px; height: 48px; border-radius: 0; border: none;
      background: transparent; color: var(--activity-fg-inactive); position: relative;
    }
    .tool-rail .icon-btn:hover, .auto-tool-rail .icon-btn:hover {
      color: var(--activity-fg); background: transparent;
    }
    .tool-rail .icon-btn.active, .tool-rail .icon-btn[aria-pressed="true"],
    .auto-tool-rail .icon-btn.active, .auto-tool-rail .icon-btn[aria-pressed="true"] {
      color: var(--activity-fg); background: transparent;
    }
    .tool-rail .icon-btn.active::before, .tool-rail .icon-btn[aria-pressed="true"]::before,
    .auto-tool-rail .icon-btn.active::before, .auto-tool-rail .icon-btn[aria-pressed="true"]::before {
      content: ''; position: absolute; left: 0; top: 8px; bottom: 8px; width: 2px;
      background: var(--activity-active-border);
    }
    .tool-rail .icon-btn svg, .auto-tool-rail .icon-btn svg { width: 24px; height: 24px; }

    /* ── Panel (Right - VS Code Sidebar style) ──────────── */
    .panel, .properties {
      background: var(--surface); border-left: 1px solid var(--border); border-right: none;
      overflow-y: auto; padding: 0; flex-shrink: 0;
    }
    .panel-section { border-bottom: 1px solid var(--border); }
    .panel-header {
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 8px 0 20px; cursor: pointer; user-select: none;
      background: var(--surface-3); height: 22px; transition: background 0.1s;
      position: relative;
    }
    .panel-header:hover { background: var(--hover); }
    .panel-header h3 { margin: 0; pointer-events: none; color: var(--text-bright); font-size: 11px; font-weight: bold; text-transform: none; }
    .panel-header .toggle-icon {
      width: 14px; color: var(--text); position: absolute; left: 4px; top: 4px;
      transition: transform 0.1s ease;
    }
    .panel-header .toggle-icon.collapsed { transform: rotate(-90deg); }
    .panel-body { padding: 10px; }
    .panel-body.collapsed { display: none; }

    /* ── Section Helper ─────────────────────────────────── */
    .section { margin-bottom: 12px; }
    .section-title {
      font-size: 11px; font-weight: 600; color: var(--text); margin-bottom: 8px;
      display: flex; align-items: center; gap: 4px; cursor: default; text-transform: none;
    }

    /* ── Property Fields ────────────────────────────────── */
    .field { display: flex; flex-direction: column; gap: 4px; margin-bottom: 8px; }
    .field > label { font-size: 12px; }
    .field-row { display: flex; align-items: center; gap: 8px; margin-bottom: 6px; }
    .field-row > label { min-width: 80px; text-align: right; flex-shrink: 0; }
    .field-row > input, .field-row > select { flex: 1; }
    .field-inline {
      display: grid; grid-template-columns: 80px 1fr; gap: 8px; align-items: center;
      margin-bottom: 6px; font-size: 12px;
    }
    .field-inline > label { text-align: right; color: var(--text); font-size: 12px; }

    /* ── List Items ─────────────────────────────────────── */
    .list-item {
      padding: 4px 8px; cursor: pointer; border-radius: var(--radius); font-size: 13px;
      display: flex; align-items: center; gap: 6px; transition: background 0.05s; margin-bottom: 2px;
    }
    .list-item:hover { background: var(--hover); }
    .list-item.selected { background: var(--selection); color: var(--text-bright); }
    .list-item .item-icon { width: 16px; height: 16px; flex-shrink: 0; }
    .list-item .item-label { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .list-item .item-badge {
      font-size: 10px; padding: 1px 5px; border-radius: 10px; background: var(--accent-dim); color: var(--accent);
    }

    /* ── Status Bar (Bottom - VS Code Status Bar style) ─── */
    .status-bar {
      display: flex; align-items: center; gap: 12px; padding: 0 10px;
      background: var(--vscode-statusBar-background);
      color: var(--vscode-statusBar-foreground);
      font-size: 12px; flex-shrink: 0; min-height: 22px; z-index: var(--z-toolbar);
    }
    .status-bar .spacer { flex: 1; }
    .status-bar .status-group { display: flex; align-items: center; gap: 6px; }
    .status-bar .sep { display: none; }
    .status-bar .badge { padding: 0; background: transparent; color: inherit; }
    .status-bar span { padding: 0 6px; height: 100%; display: flex; align-items: center; cursor: default; }
    .status-bar span:hover { background: var(--vscode-statusBarItem-hoverBackground); }
    
    /* ── Toast Notifications ────────────────────────────── */
    .toast-container {
      position: fixed; bottom: 32px; right: 16px; z-index: var(--z-toast);
      display: flex; flex-direction: column-reverse; gap: 8px;
    }
    .toast {
      padding: 10px 16px; border-radius: var(--radius); font-size: 13px; color: var(--text-bright);
      background: var(--vscode-notifications-background, var(--surface)); 
      border: 1px solid var(--vscode-notifications-border, var(--border));
      box-shadow: 0 4px 16px rgba(0,0,0,0.2); animation: toastIn 0.2s ease; max-width: 320px;
    }
    .toast.info { border-left: 4px solid var(--vscode-notificationsInfoIcon-foreground, var(--accent)); }
    .toast.success { border-left: 4px solid var(--vscode-notificationsSuccessIcon-foreground, var(--success)); }
    .toast.warn { border-left: 4px solid var(--vscode-notificationsWarningIcon-foreground, var(--warning)); }
    .toast.error { border-left: 4px solid var(--vscode-notificationsErrorIcon-foreground, var(--danger)); }
    @keyframes toastIn { from { opacity: 0; transform: translateX(8px); } to { opacity: 1; transform: translateX(0); } }

    /* ── Modal / Dialog ─────────────────────────────────── */
    .modal-overlay {
      position: fixed; inset: 0; background: var(--vscode-widget-shadow, rgba(0,0,0,0.5));
      z-index: var(--z-modal); display: flex; align-items: center; justify-content: center;
    }
    .modal {
      background: var(--vscode-editorWidget-background, var(--surface)); 
      border: 1px solid var(--vscode-editorWidget-border, var(--border));
      border-radius: var(--radius); padding: 20px; min-width: 400px; max-width: 600px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.3); color: var(--vscode-editorWidget-foreground, var(--text));
    }
    .modal h2 { margin-bottom: 16px; font-weight: normal; font-size: 14px; }
    .modal-actions { display: flex; gap: 8px; justify-content: flex-end; margin-top: 24px; }

    /* ── Shortcut Help ──────────────────────────────────── */
    .shortcut-help-table { width: 100%; border-collapse: collapse; font-size: 13px; margin-top: 12px; }
    .shortcut-help-table tr { border-bottom: 1px solid var(--border); }
    .shortcut-help-table tr:last-child { border-bottom: none; }
    .shortcut-help-table td { padding: 8px 4px; vertical-align: middle; }
    .shortcut-help-table td:first-child { width: 140px; }
    .shortcut-help-empty { color: var(--text-dim); margin-top: 12px; }

    /* ── Action Palette ─────────────────────────────────── */
    .action-palette-search { width: 100%; margin: 8px 0; padding: 6px; font-size: 14px; }
    .action-palette-list {
      max-height: 300px; overflow-y: auto; border: 1px solid var(--border);
      background: var(--bg); border-radius: var(--radius);
    }
    .action-palette-item {
      width: 100%; text-align: left; display: flex; align-items: center; justify-content: space-between; gap: 8px;
      padding: 6px 8px; border: none; background: transparent; color: var(--text); cursor: pointer; font-size: 13px;
    }
    .action-palette-item:hover, .action-palette-item.active { background: var(--selection); color: var(--text-bright); }
    .action-palette-item .hint { color: var(--text-dim); font-size: 11px; }
    kbd {
      display: inline-block; background: var(--surface-2); border: 1px solid var(--border);
      border-radius: 3px; padding: 2px 6px; font-size: 11px; font-family: var(--font-mono); color: var(--text);
    }

    /* ── Context Menu ────────────────────────────────────── */
    .context-menu {
      position: fixed; z-index: var(--z-dropdown); background: var(--vscode-menu-background, var(--surface));
      border: 1px solid var(--vscode-menu-border, var(--border)); border-radius: var(--radius);
      padding: 4px 0; min-width: 160px; box-shadow: 0 2px 8px rgba(0,0,0,0.15);
      color: var(--vscode-menu-foreground, var(--text));
    }
    .context-menu-item {
      padding: 6px 12px; font-size: 13px; cursor: pointer; display: flex; align-items: center; gap: 8px;
    }
    .context-menu-item:hover { background: var(--vscode-menu-selectionBackground, var(--selection)); color: var(--vscode-menu-selectionForeground, var(--text-bright)); }
    .context-menu-item.disabled { opacity: 0.5; pointer-events: none; }
    .context-menu-sep { height: 1px; background: var(--vscode-menu-separatorBackground, var(--border)); margin: 4px 0; }

    /* ── Canvas Area ─────────────────────────────────────── */
    .canvas-area {
      position: relative; overflow: hidden; background: var(--bg);
      flex: 1; display: flex; align-items: center; justify-content: center;
    }
    .canvas-area canvas { display: block; image-rendering: pixelated; }

    /* ── Splitter / Resize Handle ────────────────────────── */
    .splitter-h {
      width: 4px; cursor: col-resize; background: transparent;
      transition: background 0.15s; flex-shrink: 0; border-left: 1px solid var(--border);
    }
    .splitter-h:hover, .splitter-h.dragging { background: var(--accent); }
    .splitter-v {
      height: 4px; cursor: row-resize; background: transparent;
      transition: background 0.15s; flex-shrink: 0; border-top: 1px solid var(--border);
    }
    .splitter-v:hover, .splitter-v.dragging { background: var(--accent); }

    /* ── Utility ─────────────────────────────────────────── */
    .hidden { display: none !important; }
    .truncate { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .flex { display: flex; } .flex-col { display: flex; flex-direction: column; }
    .flex-1 { flex: 1; min-width: 0; min-height: 0; }
    .gap-2 { gap: 2px; } .gap-4 { gap: 4px; } .gap-8 { gap: 8px; }
    .p-4 { padding: 4px; } .p-8 { padding: 8px; }
    .items-center { align-items: center; } .justify-between { justify-content: space-between; }

    /* ── Tooltip ──────────────────────────────────────────── */
    [data-tooltip] { position: relative; }
    [data-tooltip]:hover::after {
      content: attr(data-tooltip); position: absolute; bottom: calc(100% + 4px);
      left: 50%; transform: translateX(-50%); padding: 4px 8px;
      background: var(--vscode-editorHoverWidget-background, var(--surface-3));
      color: var(--vscode-editorHoverWidget-foreground, var(--text-bright)); font-size: 12px;
      border: 1px solid var(--vscode-editorHoverWidget-border, var(--border));
      white-space: nowrap; pointer-events: none; z-index: var(--z-dropdown); box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }

    /* ── Empty State ─────────────────────────────────────── */
    .empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 12px; padding: 40px; color: var(--text-dim); text-align: center; }
    .empty-state svg { width: 64px; height: 64px; opacity: 0.5; }
    .empty-state p { max-width: 300px; line-height: 1.4; }

    /* ── Responsive ─────────────────────────────────────── */
    @media (max-width: 980px) {
      .toolbar { gap: 4px; }
      .toolbar .group { flex-wrap: wrap; }
      .status-bar { flex-wrap: wrap; }
    }
  `;
}

// ─── Shared Client-Side JS ────────────────────────────────────────────────────

export function getSharedScripts(): string {
  return `
    // ── Undo / Redo Stack ────────────────────────────────
    class UndoStack {
      constructor(maxSize = 100) {
        this._stack = []; this._idx = -1; this._max = maxSize;
        this._onChange = null;
      }
      push(state) {
        this._stack = this._stack.slice(0, this._idx + 1);
        this._stack.push(JSON.parse(JSON.stringify(state)));
        if (this._stack.length > this._max) this._stack.shift();
        else this._idx++;
        this._notify();
      }
      undo() {
        if (this._idx <= 0) return null;
        this._idx--;
        this._notify();
        return JSON.parse(JSON.stringify(this._stack[this._idx]));
      }
      redo() {
        if (this._idx >= this._stack.length - 1) return null;
        this._idx++;
        this._notify();
        return JSON.parse(JSON.stringify(this._stack[this._idx]));
      }
      get canUndo() { return this._idx > 0; }
      get canRedo() { return this._idx < this._stack.length - 1; }
      onChange(fn) { this._onChange = fn; }
      _notify() { if (this._onChange) this._onChange(this.canUndo, this.canRedo); }
    }

    // ── Toast Notifications ──────────────────────────────
    const _toastContainer = document.createElement('div');
    _toastContainer.className = 'toast-container';
    document.body.appendChild(_toastContainer);

    function showToast(message, type = 'info', duration = 3000) {
      const t = document.createElement('div');
      t.className = 'toast ' + type;
      t.textContent = message;
      _toastContainer.appendChild(t);
      setTimeout(() => { t.style.opacity = '0'; setTimeout(() => t.remove(), 200); }, duration);
    }

    // ── Keyboard Shortcuts ───────────────────────────────
    const _keyHandlers = {};
    const _shortcutLabels = {};
    function registerShortcut(key, fn, description = '') {
      const normalized = String(key || '').toLowerCase();
      if (!normalized) return;
      _keyHandlers[normalized] = fn;
      if (description && !_shortcutLabels[normalized]) {
        _shortcutLabels[normalized] = description;
      }
    }

    function normalizeKeyName(name) {
      const n = String(name || '').toLowerCase();
      if (n === ' ') return 'space';
      if (n === 'esc') return 'escape';
      if (n === 'arrowup') return 'up';
      if (n === 'arrowdown') return 'down';
      if (n === 'arrowleft') return 'left';
      if (n === 'arrowright') return 'right';
      return n;
    }

    function formatShortcut(key) {
      return String(key || '')
        .split('+')
        .map((part) => {
          const p = part.trim().toLowerCase();
          if (p === 'ctrl') return 'Ctrl';
          if (p === 'shift') return 'Shift';
          if (p === 'alt') return 'Alt';
          if (p === 'meta') return 'Meta';
          if (p === 'space') return 'Space';
          if (!p) return '';
          return p.length === 1 ? p.toUpperCase() : (p.charAt(0).toUpperCase() + p.slice(1));
        })
        .filter(Boolean)
        .join(' + ');
    }

    function parseShortcutFromTitle(title) {
      const m = /\(([^)]+)\)/.exec(String(title || ''));
      if (!m) return null;
      return m[1].trim().toLowerCase();
    }

    function actionLabelFromElement(el) {
      if (!el) return '';
      const title = (el.getAttribute('title') || '').trim();
      if (title) {
        return title.replace(/\s*\([^)]*\)\s*$/, '').trim();
      }
      const aria = (el.getAttribute('aria-label') || '').trim();
      if (aria) return aria;
      const text = (el.textContent || '').replace(/\s+/g, ' ').trim();
      if (text) return text;
      if (el.id) return el.id;
      return 'Action';
    }

    function collectKnownShortcuts() {
      const rows = {};

      Object.keys(_keyHandlers).forEach((key) => {
        rows[key] = rows[key] || { key, label: _shortcutLabels[key] || '' };
      });

      document.querySelectorAll('[title]').forEach((el) => {
        const shortcut = parseShortcutFromTitle(el.getAttribute('title'));
        if (!shortcut) return;
        if (!rows[shortcut]) {
          rows[shortcut] = {
            key: shortcut,
            label: el.getAttribute('aria-label') || el.getAttribute('title') || '',
          };
        }
      });

      const list = Object.values(rows)
        .filter((row) => row.key && row.key !== '?' && row.key !== 'shift+/')
        .sort((a, b) => a.key.localeCompare(b.key));

      return list;
    }

    function collectActionButtons() {
      const seen = {};
      const actions = [];
      const selector = '.toolbar button, .tool-rail button, .panel button, .properties button, .tabs button';

      document.querySelectorAll(selector).forEach((btn) => {
        if (!(btn instanceof HTMLButtonElement)) return;
        if (btn.disabled) return;
        if (!btn.offsetParent && btn.id !== 'btnHelpShortcuts') return;
        const key = btn.id || actionLabelFromElement(btn);
        if (!key || seen[key]) return;
        seen[key] = true;

        const rawTitle = (btn.getAttribute('title') || '').trim();
        const shortcut = parseShortcutFromTitle(rawTitle);
        actions.push({
          key,
          label: actionLabelFromElement(btn),
          shortcut: shortcut ? formatShortcut(shortcut) : '',
          run: () => btn.click(),
        });
      });

      return actions.sort((a, b) => a.label.localeCompare(b.label));
    }

    let _shortcutModal = null;
    function closeShortcutHelp() {
      if (_shortcutModal) {
        _shortcutModal.remove();
        _shortcutModal = null;
      }
    }

    function showShortcutHelp() {
      closeShortcutHelp();
      const rows = collectKnownShortcuts();

      const overlay = document.createElement('div');
      overlay.className = 'modal-overlay';

      const dialog = document.createElement('div');
      dialog.className = 'modal';
      dialog.setAttribute('role', 'dialog');
      dialog.setAttribute('aria-label', 'Keyboard Shortcuts');
      dialog.innerHTML = '<h2>Keyboard Shortcuts</h2>';

      if (!rows.length) {
        const empty = document.createElement('p');
        empty.className = 'shortcut-help-empty';
        empty.textContent = 'No shortcuts are registered in this editor.';
        dialog.appendChild(empty);
      } else {
        const table = document.createElement('table');
        table.className = 'shortcut-help-table';
        const tbody = document.createElement('tbody');

        rows.forEach((row) => {
          const tr = document.createElement('tr');
          const keyCell = document.createElement('td');
          keyCell.innerHTML = '<kbd>' + formatShortcut(row.key) + '</kbd>';
          const descCell = document.createElement('td');
          descCell.textContent = row.label || 'Action';
          tr.appendChild(keyCell);
          tr.appendChild(descCell);
          tbody.appendChild(tr);
        });

        table.appendChild(tbody);
        dialog.appendChild(table);
      }

      const actions = document.createElement('div');
      actions.className = 'modal-actions';
      const closeBtn = document.createElement('button');
      closeBtn.type = 'button';
      closeBtn.className = 'primary';
      closeBtn.textContent = 'Close';
      closeBtn.addEventListener('click', closeShortcutHelp);
      actions.appendChild(closeBtn);
      dialog.appendChild(actions);

      overlay.appendChild(dialog);
      overlay.addEventListener('click', (ev) => {
        if (ev.target === overlay) closeShortcutHelp();
      });
      document.body.appendChild(overlay);
      _shortcutModal = overlay;
      closeBtn.focus();
    }

    let _actionPalette = null;
    function closeActionPalette() {
      if (_actionPalette) {
        _actionPalette.remove();
        _actionPalette = null;
      }
    }

    function renderActionPaletteList(container, searchValue, onRun, onMove, selectedIdx) {
      container.innerHTML = '';
      const query = String(searchValue || '').trim().toLowerCase();
      const actions = collectActionButtons().filter((a) => {
        if (!query) return true;
        return a.label.toLowerCase().includes(query) || a.shortcut.toLowerCase().includes(query);
      });

      if (!actions.length) {
        const empty = document.createElement('div');
        empty.className = 'action-palette-empty';
        empty.textContent = 'No matching actions.';
        container.appendChild(empty);
        onMove(-1, []);
        return;
      }

      actions.forEach((action, idx) => {
        const row = document.createElement('button');
        row.type = 'button';
        row.className = 'action-palette-item' + (idx === selectedIdx ? ' active' : '');
        row.innerHTML = '<span>' + action.label + '</span>' + (action.shortcut ? '<span class="hint"><kbd>' + action.shortcut + '</kbd></span>' : '');
        row.addEventListener('click', () => onRun(action));
        container.appendChild(row);
      });

      onMove(selectedIdx, actions);
    }

    function showActionPalette() {
      closeShortcutHelp();
      closeActionPalette();

      const overlay = document.createElement('div');
      overlay.className = 'modal-overlay';

      const dialog = document.createElement('div');
      dialog.className = 'modal';
      dialog.setAttribute('role', 'dialog');
      dialog.setAttribute('aria-label', 'Action Palette');
      dialog.innerHTML = '<h2>Action Palette</h2>';

      const search = document.createElement('input');
      search.className = 'action-palette-search';
      search.placeholder = 'Type action name...';

      const list = document.createElement('div');
      list.className = 'action-palette-list';

      const actions = document.createElement('div');
      actions.className = 'modal-actions';
      const closeBtn = document.createElement('button');
      closeBtn.type = 'button';
      closeBtn.textContent = 'Close';
      closeBtn.addEventListener('click', closeActionPalette);
      actions.appendChild(closeBtn);

      dialog.appendChild(search);
      dialog.appendChild(list);
      dialog.appendChild(actions);
      overlay.appendChild(dialog);

      let selected = 0;
      let currentActions = [];
      const runAction = (action) => {
        closeActionPalette();
        action.run();
      };
      const setActions = (selectedIdx, actionsList) => {
        currentActions = actionsList;
        if (!currentActions.length) {
          selected = -1;
          return;
        }
        if (selectedIdx < 0 || selectedIdx >= currentActions.length) {
          selected = 0;
        } else {
          selected = selectedIdx;
        }
      };

      const rerender = () => {
        renderActionPaletteList(list, search.value, runAction, setActions, selected);
      };

      search.addEventListener('input', () => {
        selected = 0;
        rerender();
      });

      search.addEventListener('keydown', (e) => {
        if (e.key === 'ArrowDown') {
          e.preventDefault();
          if (!currentActions.length) return;
          selected = (selected + 1) % currentActions.length;
          rerender();
        } else if (e.key === 'ArrowUp') {
          e.preventDefault();
          if (!currentActions.length) return;
          selected = (selected - 1 + currentActions.length) % currentActions.length;
          rerender();
        } else if (e.key === 'Enter') {
          e.preventDefault();
          if (currentActions[selected]) runAction(currentActions[selected]);
        }
      });

      overlay.addEventListener('click', (ev) => {
        if (ev.target === overlay) closeActionPalette();
      });

      document.body.appendChild(overlay);
      _actionPalette = overlay;
      rerender();
      search.focus();
    }

    function wireAutoDirtyFromForms() {
      const onFormChanged = (event) => {
        const target = event && event.target;
        if (!target || !(target instanceof HTMLElement)) return;
        if (target.closest('[data-no-dirty]')) return;

        const tag = target.tagName.toLowerCase();
        const isInput = tag === 'input' || tag === 'textarea' || tag === 'select';
        if (!isInput) return;
        markDirty();
      };

      document.addEventListener('change', onFormChanged, true);
      document.addEventListener('input', onFormChanged, true);
    }

    function injectHelpButton() {
      const toolbar = document.querySelector('.toolbar');
      if (!toolbar || document.getElementById('btnHelpShortcuts')) return;

      const group = document.createElement('div');
      group.className = 'group';
      const btn = document.createElement('button');
      btn.id = 'btnHelpShortcuts';
      btn.type = 'button';
      btn.className = 'icon-btn help-btn';
      btn.textContent = '?';
      btn.title = 'Keyboard shortcuts (?)';
      btn.setAttribute('aria-label', 'Open keyboard shortcuts help');
      btn.addEventListener('click', showShortcutHelp);
      group.appendChild(btn);
      toolbar.appendChild(group);
    }

    function createRailButtonFrom(originalBtn) {
      const b = document.createElement('button');
      b.type = 'button';
      b.className = 'icon-btn';
      const title = originalBtn.getAttribute('title') || originalBtn.getAttribute('aria-label') || actionLabelFromElement(originalBtn);
      b.setAttribute('title', title || 'Action');
      b.setAttribute('aria-label', title || 'Action');

      const svg = originalBtn.querySelector('svg');
      if (svg) {
        b.innerHTML = svg.outerHTML;
      } else {
        const text = (originalBtn.textContent || '').trim();
        b.textContent = text ? text.substring(0, 2).toUpperCase() : '•';
      }

      const syncState = () => {
        b.disabled = !!originalBtn.disabled;
        b.classList.toggle('active', originalBtn.classList.contains('active') || originalBtn.getAttribute('aria-pressed') === 'true');
      };

      b.addEventListener('click', () => originalBtn.click());
      syncState();
      const observer = new MutationObserver(syncState);
      observer.observe(originalBtn, { attributes: true, attributeFilter: ['class', 'aria-pressed', 'disabled'] });
      return b;
    }

    function ensureVoxelStyleLayout() {
      const toolbar = document.querySelector('.toolbar');
      if (!toolbar) return;

      const hasNativeRail = !!document.querySelector('.tool-rail');
      if (hasNativeRail || document.querySelector('.auto-tool-rail')) return;

      const candidates = Array.from(toolbar.querySelectorAll('button'))
        .filter((btn) => btn instanceof HTMLButtonElement)
        .filter((btn) => !btn.classList.contains('primary'))
        .filter((btn) => btn.id !== 'btnExport' && btn.id !== 'btnHelpShortcuts')
        .filter((btn) => !btn.closest('.spacer'));

      if (!candidates.length) return;

      const rail = document.createElement('div');
      rail.className = 'auto-tool-rail';
      const maxButtons = 10;
      candidates.slice(0, maxButtons).forEach((btn, idx) => {
        if (idx > 0 && idx % 4 === 0) {
          const sep = document.createElement('div');
          sep.className = 'tool-rail-sep';
          rail.appendChild(sep);
        }
        rail.appendChild(createRailButtonFrom(btn));
        btn.style.display = "none";
      });

      const layout = document.querySelector('.editor-layout'); if (layout) layout.appendChild(rail); else const layout = document.querySelector(".editor-layout"); if (layout) layout.insertBefore(rail, toolbar.nextSibling); else document.body.appendChild(rail);
    }

    document.addEventListener('keydown', (e) => {
      const tag = (e.target && e.target.tagName ? e.target.tagName.toLowerCase() : '');
      const isTypingTarget = tag === 'input' || tag === 'textarea' || tag === 'select' || (e.target && e.target.isContentEditable);
      if (isTypingTarget && !(e.ctrlKey || e.metaKey || e.altKey)) {
        return;
      }

      const parts = [];
      if (e.ctrlKey || e.metaKey) parts.push('ctrl');
      if (e.shiftKey) parts.push('shift');
      if (e.altKey) parts.push('alt');
      parts.push(normalizeKeyName(e.key));
      const combo = parts.join('+');
      if (_keyHandlers[combo]) { e.preventDefault(); _keyHandlers[combo](e); }
    });

    // ── Collapsible Panel Sections ───────────────────────
    function initCollapsibleSections() {
      document.querySelectorAll('.panel-header').forEach(header => {
        header.addEventListener('click', () => {
          const body = header.nextElementSibling;
          const icon = header.querySelector('.toggle-icon');
          if (body) body.classList.toggle('collapsed');
          if (icon) icon.classList.toggle('collapsed');
        });
      });
    }

    // ── Context Menu ─────────────────────────────────────
    let _activeCtxMenu = null;
    function showContextMenu(x, y, items) {
      hideContextMenu();
      const menu = document.createElement('div');
      menu.className = 'context-menu';
      menu.style.left = x + 'px'; menu.style.top = y + 'px';
      items.forEach(item => {
        if (item === 'sep') {
          const sep = document.createElement('div');
          sep.className = 'context-menu-sep';
          menu.appendChild(sep);
        } else {
          const el = document.createElement('div');
          el.className = 'context-menu-item' + (item.disabled ? ' disabled' : '');
          el.textContent = item.label;
          if (item.icon) el.insertAdjacentHTML('afterbegin', item.icon);
          el.addEventListener('click', () => { hideContextMenu(); if (item.action) item.action(); });
          menu.appendChild(el);
        }
      });
      document.body.appendChild(menu);
      _activeCtxMenu = menu;
      // Clamp to viewport
      const rect = menu.getBoundingClientRect();
      if (rect.right > window.innerWidth) menu.style.left = (window.innerWidth - rect.width - 4) + 'px';
      if (rect.bottom > window.innerHeight) menu.style.top = (window.innerHeight - rect.height - 4) + 'px';
    }
    function hideContextMenu() { if (_activeCtxMenu) { _activeCtxMenu.remove(); _activeCtxMenu = null; } }
    document.addEventListener('click', hideContextMenu);
    document.addEventListener('contextmenu', (e) => { if (!_activeCtxMenu) return; });

    // ── Resizable Splitter ───────────────────────────────
    function initSplitter(splitterEl, beforeEl, afterEl, direction = 'horizontal', minPx = 120) {
      let startPos, startBeforeSize;
      splitterEl.addEventListener('mousedown', (e) => {
        e.preventDefault();
        splitterEl.classList.add('dragging');
        startPos = direction === 'horizontal' ? e.clientX : e.clientY;
        startBeforeSize = direction === 'horizontal' ? beforeEl.offsetWidth : beforeEl.offsetHeight;
        const onMove = (ev) => {
          const delta = (direction === 'horizontal' ? ev.clientX : ev.clientY) - startPos;
          const newSize = Math.max(minPx, startBeforeSize + delta);
          beforeEl.style[direction === 'horizontal' ? 'width' : 'height'] = newSize + 'px';
        };
        const onUp = () => {
          splitterEl.classList.remove('dragging');
          document.removeEventListener('mousemove', onMove);
          document.removeEventListener('mouseup', onUp);
        };
        document.addEventListener('mousemove', onMove);
        document.addEventListener('mouseup', onUp);
      });
    }

    // ── Export Dropdown ──────────────────────────────────
    function createExportDropdown(buttonEl, options) {
      buttonEl.addEventListener('click', (e) => {
        e.stopPropagation();
        const rect = buttonEl.getBoundingClientRect();
        showContextMenu(rect.left, rect.bottom + 2, options.map(o => ({
          label: o.label,
          icon: o.icon || '',
          action: o.action,
        })));
      });
    }

    // ── Dirty State Helper ───────────────────────────────
    let _isDirty = false;
    function markDirty() {
      _isDirty = true;
      document.querySelectorAll('.dirty-indicator').forEach(el => {
        el.innerHTML = '${ICONS.dirty}';
        el.setAttribute('data-tooltip', 'Unsaved changes');
      });
      vscode.postMessage({ type: 'stateChanged', dirty: true });
    }
    function markClean() {
      _isDirty = false;
      document.querySelectorAll('.dirty-indicator').forEach(el => {
        el.innerHTML = '${ICONS.clean}';
        el.setAttribute('data-tooltip', 'All changes saved');
      });
      vscode.postMessage({ type: 'stateChanged', dirty: false });
    }

    // Register default keyboard shortcuts
    registerShortcut('ctrl+z', () => { document.getElementById('btnUndo')?.click(); });
    registerShortcut('ctrl+shift+z', () => { document.getElementById('btnRedo')?.click(); });
    registerShortcut('ctrl+y', () => { document.getElementById('btnRedo')?.click(); });
    registerShortcut('ctrl+s', () => { document.getElementById('btnExport')?.click(); });
    registerShortcut('f1', () => showShortcutHelp(), 'Show keyboard shortcuts');
    registerShortcut('?', () => showShortcutHelp(), 'Show keyboard shortcuts');
    registerShortcut('shift+/', () => showShortcutHelp(), 'Show keyboard shortcuts');
    registerShortcut('ctrl+k', () => showActionPalette(), 'Open action palette');
    registerShortcut('ctrl+.', () => showActionPalette(), 'Open action palette');
    registerShortcut('escape', () => {
      hideContextMenu();
      closeShortcutHelp();
      closeActionPalette();
    });

    // Init collapsible sections when DOM ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        initCollapsibleSections();
        injectHelpButton();
        ensureVoxelStyleLayout();
        wireAutoDirtyFromForms();
      });
    } else {
      initCollapsibleSections();
      injectHelpButton();
      ensureVoxelStyleLayout();
      wireAutoDirtyFromForms();
    }
  `;
}

// ─── HTML Wrapper ─────────────────────────────────────────────────────────────

export function wrapHtml(
  nonce: string,
  title: string,
  extraCss: string,
  body: string,
  scripts: string
): string {
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
${getSharedScripts()}
${scripts}
</script>
</body>
</html>`;
}

// ─── Helpers for building standard toolbar HTML ───────────────────────────────

export function toolbarSep(): string {
  return '<div class="sep"></div>';
}

export function toolbarSpacer(): string {
  return '<div class="spacer"></div>';
}

export function iconButton(icon: keyof typeof ICONS, opts: {
  id?: string; title?: string; className?: string; ariaPressed?: boolean;
} = {}): string {
  const cls = ['icon-btn', opts.className || ''].filter(Boolean).join(' ');
  const pressed = opts.ariaPressed ? ' aria-pressed="true"' : '';
  const idAttr = opts.id ? ` id="${opts.id}"` : '';
  const escapedTitle = opts.title ? opts.title.replace(/"/g, '&quot;') : '';
  const titleAttr = opts.title ? ` title="${opts.title}" data-tooltip="${opts.title}"` : '';
  const ariaAttr = escapedTitle ? ` aria-label="${escapedTitle}"` : '';
  return `<button type="button" class="${cls}"${idAttr}${titleAttr}${ariaAttr}${pressed}>${ICONS[icon]}</button>`;
}

export function panelSection(title: string, bodyHtml: string, collapsed = false): string {
  const colClass = collapsed ? ' collapsed' : '';
  return `
    <div class="panel-section">
      <div class="panel-header">
        <h3>${title}</h3>
        <svg class="toggle-icon${colClass}" width="14" height="14" viewBox="0 0 16 16" fill="currentColor">
          <path d="M5.7 13.7L4.3 12.3 8.6 8 4.3 3.7 5.7 2.3 11.4 8z"/>
        </svg>
      </div>
      <div class="panel-body${colClass}">${bodyHtml}</div>
    </div>`;
}

export function fieldInline(label: string, inputHtml: string): string {
  return `<div class="field-inline"><label>${label}</label>${inputHtml}</div>`;
}

// ─── Abstract Base Class ──────────────────────────────────────────────────────

export abstract class WebviewEditor {
  protected panel: vscode.WebviewPanel;
  protected isDirty: boolean = false;
  private disposables: vscode.Disposable[] = [];
  private stateKey: string;

  constructor(
    protected context: vscode.ExtensionContext,
    viewType: string,
    title: string,
    protected data: Record<string, unknown> = {}
  ) {
    this.stateKey = `lurek.editorState.${viewType}`;

    this.panel = vscode.window.createWebviewPanel(
      viewType,
      title,
      vscode.ViewColumn.One,
      { enableScripts: true, retainContextWhenHidden: true }
    );

    this.panel.iconPath = vscode.Uri.joinPath(
      context.extensionUri,
      "media",
      "icon.png"
    );

    this.panel.webview.onDidReceiveMessage(
      (msg) => this.onMessage(msg),
      undefined,
      this.disposables
    );

    this.panel.onDidDispose(
      () => this.dispose(),
      undefined,
      this.disposables
    );

    this.panel.webview.html = this.getHtml();

    // Restore persisted state
    const saved = this.context.workspaceState.get<Record<string, unknown>>(this.stateKey);
    if (saved) {
      this.panel.webview.postMessage({ type: "restoreState", data: saved });
    }
  }

  private onMessage(msg: { type: string;[key: string]: unknown }): void {
    switch (msg.type) {
      case "stateChanged":
        this.isDirty = msg.dirty as boolean;
        break;
      case "persistState":
        this.context.workspaceState.update(this.stateKey, msg.data);
        break;
      case "exportLua":
        this.exportLua(msg.content as string, msg.name as string || "export.lua");
        break;
      case "exportToml":
        this.exportToml(msg.content as string, msg.name as string || "export.toml");
        break;
      case "exportJson":
        this.exportJson(msg.content as string, msg.name as string || "export.json");
        break;
      case "exportFile":
        this.exportFile(msg.content as string, msg.name as string || "export.json", "JSON", "json");
        break;
      case "exportPng":
        this.exportFile(msg.content as string, msg.name as string || "export.png", "PNG", "png");
        break;
      case "copyToClipboard":
        vscode.env.clipboard.writeText(msg.content as string).then(() => {
          vscode.window.showInformationMessage("Copied to clipboard");
        });
        break;
      case "insertToEditor": {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
          editor.edit(edit => {
            edit.insert(editor.selection.active, msg.content as string);
          });
        } else {
          vscode.window.showWarningMessage("No active text editor to insert into");
        }
        break;
      }
      case "showToast":
        if (msg.level === "error") {
          vscode.window.showErrorMessage(msg.message as string);
        } else if (msg.level === "warn") {
          vscode.window.showWarningMessage(msg.message as string);
        } else {
          vscode.window.showInformationMessage(msg.message as string);
        }
        break;
      default:
        this.handleMessage(msg);
    }
  }

  protected abstract handleMessage(msg: {
    type: string;
    [key: string]: unknown;
  }): void;
  protected abstract getHtml(): string;

  protected async exportFile(
    content: string,
    defaultName: string,
    filterLabel: string,
    ext: string
  ): Promise<void> {
    const uri = await vscode.window.showSaveDialog({
      defaultUri: vscode.Uri.file(defaultName),
      filters: { [filterLabel]: [ext] },
    });
    if (uri) {
      await vscode.workspace.fs.writeFile(
        uri,
        Buffer.from(content, "utf-8")
      );
      vscode.window.showInformationMessage(`Exported to ${uri.fsPath}`);
    }
  }

  protected async exportLua(
    content: string,
    defaultName: string
  ): Promise<void> {
    return this.exportFile(content, defaultName, "Lua", "lua");
  }

  protected async exportToml(
    content: string,
    defaultName: string
  ): Promise<void> {
    await this.exportFile(content, defaultName, "TOML Files", "toml");
  }

  protected async exportJson(
    content: string,
    defaultName: string
  ): Promise<void> {
    await this.exportFile(content, defaultName, "JSON Files", "json");
  }

  dispose(): void {
    // Persist state on close
    if (this.isDirty) {
      this.panel.webview.postMessage({ type: "requestState" });
    }
    for (const d of this.disposables) {
      d.dispose();
    }
  }
}
