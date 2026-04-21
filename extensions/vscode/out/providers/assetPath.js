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
exports.register = register;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const luaParser_js_1 = require("../services/luaParser.js");
const LUA_SELECTOR = { scheme: 'file', language: 'lua' };
const analyzer = new luaParser_js_1.LuaDocumentAnalyzer();
/** Maps asset function patterns to their expected file extensions. */
const ASSET_FUNC_EXTENSIONS = {
    'lurek.graphics.newImage': ['.png', '.jpg', '.jpeg', '.bmp', '.gif'],
    'lurek.audio.newSource': ['.ogg', '.wav', '.mp3', '.flac'],
    'lurek.filesystem.read': [],
    'lurek.filesystem.write': [],
    'lurek.filesystem.exists': [],
};
/** Extensions shown for require() completions. */
const LUA_EXTENSIONS = ['.lua'];
/**
 * Registers the asset path completion provider.
 * Completes file paths inside string arguments to asset-loading and require functions.
 */
function register(context, apiData) {
    const provider = vscode.languages.registerCompletionItemProvider(LUA_SELECTOR, {
        async provideCompletionItems(document, position) {
            try {
                return await getAssetCompletions(document, position);
            }
            catch {
                return undefined;
            }
        },
    }, '"', "'", '/');
    context.subscriptions.push(provider);
}
async function getAssetCompletions(document, position) {
    const lineText = document.lineAt(position).text;
    const textBefore = lineText.substring(0, position.character);
    // Try matching an asset-loading function: lurek.module.func("partial_path
    const assetMatch = textBefore.match(/(lurek\.\w+\.\w+)\s*\(\s*["']([^"']*)$/);
    // Try matching require: require("partial_path
    const requireMatch = textBefore.match(/require\s*\(\s*["']([^"']*)$/);
    if (!assetMatch && !requireMatch)
        return undefined;
    const funcPath = assetMatch ? assetMatch[1] : 'require';
    const partialPath = assetMatch ? assetMatch[2] : requireMatch[1];
    // Determine extensions filter
    let extensions = [];
    if (funcPath === 'require') {
        extensions = LUA_EXTENSIONS;
    }
    else if (funcPath in ASSET_FUNC_EXTENSIONS) {
        extensions = ASSET_FUNC_EXTENSIONS[funcPath];
    }
    else {
        return undefined;
    }
    const workspaceRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!workspaceRoot)
        return undefined;
    // Build glob pattern
    const searchDir = partialPath.includes('/') ? path.dirname(partialPath) : '';
    const globPattern = searchDir ? `${searchDir}/**/*` : '**/*';
    const files = await vscode.workspace.findFiles(globPattern, '**/node_modules/**', 200);
    const items = [];
    const seenDirs = new Set();
    for (const file of files) {
        const ext = path.extname(file.fsPath).toLowerCase();
        // Filter by expected extensions (empty = allow all)
        if (extensions.length > 0 && !extensions.includes(ext))
            continue;
        const relativePath = path.relative(workspaceRoot, file.fsPath).replace(/\\/g, '/');
        // For require(), strip .lua extension and use dot-separated paths
        if (funcPath === 'require') {
            const requirePath = relativePath
                .replace(/\.lua$/, '')
                .replace(/\//g, '.');
            const item = new vscode.CompletionItem(requirePath, vscode.CompletionItemKind.Module);
            item.detail = 'Lua module';
            item.insertText = requirePath;
            const depth = requirePath.split('.').length;
            item.sortText = String(depth).padStart(3, '0') + requirePath;
            items.push(item);
            continue;
        }
        // Add folder completions
        const dir = path.dirname(relativePath);
        if (dir !== '.' && !seenDirs.has(dir)) {
            seenDirs.add(dir);
            // Only add dir completion if it matches partial path prefix
            if (!partialPath || dir.startsWith(partialPath.split('/')[0])) {
                const dirItem = new vscode.CompletionItem(dir + '/', vscode.CompletionItemKind.Folder);
                dirItem.sortText = '0' + dir;
                items.push(dirItem);
            }
        }
        const item = new vscode.CompletionItem(relativePath, vscode.CompletionItemKind.File);
        item.detail = ext.toUpperCase().substring(1) + ' file';
        item.insertText = relativePath;
        // Sort by depth — nearby files first
        const depth = relativePath.split('/').length;
        item.sortText = String(depth).padStart(3, '0') + relativePath;
        items.push(item);
    }
    return items;
}
//# sourceMappingURL=assetPath.js.map