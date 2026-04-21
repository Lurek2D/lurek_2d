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
exports.AssetExplorerProvider = exports.AssetItem = void 0;
exports.findMissingAssets = findMissingAssets;
exports.insertAssetPath = insertAssetPath;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
// ── Asset item ───────────────────────────────────────────────
class AssetItem extends vscode.TreeItem {
    label;
    collapsibleState;
    resourceUri;
    assetType;
    sizeBytes;
    constructor(label, collapsibleState, resourceUri, assetType, sizeBytes) {
        super(label, collapsibleState);
        this.label = label;
        this.collapsibleState = collapsibleState;
        this.resourceUri = resourceUri;
        this.assetType = assetType;
        this.sizeBytes = sizeBytes;
        if (resourceUri) {
            this.resourceUri = resourceUri;
            this.tooltip = resourceUri.fsPath;
        }
        this.iconPath = assetType ? new vscode.ThemeIcon(AssetItem.iconFor(assetType)) : undefined;
        if (sizeBytes !== undefined) {
            this.description = AssetItem.formatSize(sizeBytes);
        }
        if (assetType && assetType !== "folder" && resourceUri) {
            this.command = {
                command: "vscode.open",
                title: "Open File",
                arguments: [resourceUri],
            };
        }
    }
    static iconFor(kind) {
        switch (kind) {
            case "image": return "file-media";
            case "audio": return "unmute";
            case "font": return "text-size";
            case "shader": return "symbol-color";
            case "folder": return "folder";
            default: return "file";
        }
    }
    static formatSize(bytes) {
        if (bytes < 1024)
            return `${bytes} B`;
        if (bytes < 1024 * 1024)
            return `${(bytes / 1024).toFixed(1)} KB`;
        return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
    }
}
exports.AssetItem = AssetItem;
// ── Extension patterns ───────────────────────────────────────
const IMAGE_EXT = new Set([".png", ".jpg", ".jpeg", ".bmp", ".gif", ".tga", ".tiff", ".webp"]);
const AUDIO_EXT = new Set([".wav", ".ogg", ".mp3", ".flac", ".aiff"]);
const FONT_EXT = new Set([".ttf", ".otf"]);
const SHADER_EXT = new Set([".glsl", ".vert", ".frag"]);
function classifyFile(ext) {
    if (IMAGE_EXT.has(ext))
        return "image";
    if (AUDIO_EXT.has(ext))
        return "audio";
    if (FONT_EXT.has(ext))
        return "font";
    if (SHADER_EXT.has(ext))
        return "shader";
    return undefined;
}
// ── Provider ─────────────────────────────────────────────────
class AssetExplorerProvider {
    _onDidChangeTreeData = new vscode.EventEmitter();
    onDidChangeTreeData = this._onDidChangeTreeData.event;
    categories = [];
    _missingAssets = [];
    constructor() {
        this.refresh();
    }
    refresh() {
        this.categories = [
            { label: "Images", type: "image", icon: "file-media", items: [] },
            { label: "Audio", type: "audio", icon: "unmute", items: [] },
            { label: "Fonts", type: "font", icon: "text-size", items: [] },
            { label: "Shaders", type: "shader", icon: "symbol-color", items: [] },
        ];
        this._missingAssets = [];
        this._scanWorkspace();
        this._onDidChangeTreeData.fire(undefined);
    }
    get missingAssets() {
        return this._missingAssets;
    }
    _scanWorkspace() {
        const folders = vscode.workspace.workspaceFolders;
        if (!folders?.length)
            return;
        const root = folders[0].uri.fsPath;
        this._walk(root, root);
    }
    _walk(dir, root) {
        let entries;
        try {
            entries = fs.readdirSync(dir, { withFileTypes: true });
        }
        catch {
            return;
        }
        for (const entry of entries) {
            const fullPath = path.join(dir, entry.name);
            // Skip hidden dirs, node_modules, target
            if (entry.name.startsWith(".") || entry.name === "node_modules" || entry.name === "target")
                continue;
            if (entry.isDirectory()) {
                this._walk(fullPath, root);
            }
            else if (entry.isFile()) {
                const ext = path.extname(entry.name).toLowerCase();
                const kind = classifyFile(ext);
                if (!kind)
                    continue;
                const cat = this.categories.find(c => c.type === kind);
                if (!cat)
                    continue;
                let size = 0;
                try {
                    size = fs.statSync(fullPath).size;
                }
                catch { /* skip */ }
                cat.items.push({
                    name: path.relative(root, fullPath).replace(/\\/g, "/"),
                    uri: vscode.Uri.file(fullPath),
                    size,
                });
            }
        }
    }
    getTreeItem(element) {
        return element;
    }
    getChildren(element) {
        if (!element) {
            return this.categories
                .filter(cat => cat.items.length > 0)
                .map(cat => {
                const item = new AssetItem(`${cat.label} (${cat.items.length})`, vscode.TreeItemCollapsibleState.Collapsed, undefined, "folder", undefined);
                item.contextValue = `assetCategory.${cat.type}`;
                // Store type for getChildren lookup
                item._catType = cat.type;
                return item;
            });
        }
        // Find the category for this header node
        const catType = element._catType;
        if (catType) {
            const cat = this.categories.find(c => c.type === catType);
            if (!cat)
                return [];
            return cat.items.map(i => new AssetItem(path.basename(i.name), vscode.TreeItemCollapsibleState.None, i.uri, cat.type, i.size));
        }
        return [];
    }
}
exports.AssetExplorerProvider = AssetExplorerProvider;
// ── "Find missing assets" helper ─────────────────────────────
async function findMissingAssets() {
    const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!wsRoot) {
        vscode.window.showWarningMessage("No workspace folder open.");
        return;
    }
    const luaFiles = await vscode.workspace.findFiles("**/*.lua", "**/node_modules/**");
    const assetPattern = /lurek\.(?:graphics\.newImage|audio\.newSource)\s*\(\s*["']([^"']+)["']/g;
    const missing = [];
    for (const uri of luaFiles) {
        let text;
        try {
            text = fs.readFileSync(uri.fsPath, "utf8");
        }
        catch {
            continue;
        }
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; i++) {
            assetPattern.lastIndex = 0;
            let m;
            while ((m = assetPattern.exec(lines[i])) !== null) {
                const assetPath = m[1];
                if (!assetPath.includes("."))
                    continue;
                const abs = path.resolve(path.dirname(uri.fsPath), assetPath);
                const abs2 = path.resolve(wsRoot, assetPath);
                if (!fs.existsSync(abs) && !fs.existsSync(abs2)) {
                    missing.push({ file: vscode.workspace.asRelativePath(uri), line: i + 1, asset: assetPath });
                }
            }
        }
    }
    if (missing.length === 0) {
        vscode.window.showInformationMessage("No missing assets found.");
        return;
    }
    const report = missing.map(m => `${m.file}:${m.line}  →  ${m.asset}`).join("\n");
    const doc = await vscode.workspace.openTextDocument({ content: `Missing assets:\n\n${report}`, language: "plaintext" });
    vscode.window.showTextDocument(doc);
}
// ── "Insert path" command helper ─────────────────────────────
function insertAssetPath(item) {
    const editor = vscode.window.activeTextEditor;
    if (!editor || !item.resourceUri)
        return;
    const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath ?? "";
    let rel = item.resourceUri.fsPath;
    if (wsRoot && rel.startsWith(wsRoot))
        rel = rel.substring(wsRoot.length + 1);
    rel = rel.replace(/\\/g, "/");
    editor.edit(b => b.replace(editor.selection, `"${rel}"`));
}
//# sourceMappingURL=assetExplorer.js.map