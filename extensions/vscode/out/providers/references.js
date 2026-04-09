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
const luaParser_js_1 = require("../services/luaParser.js");
const LUA_SELECTOR = { scheme: "file", language: "lua" };
const analyzer = new luaParser_js_1.LuaDocumentAnalyzer();
// ── Provider registration ────────────────────────────────────
function register(context, apiData) {
    const provider = vscode.languages.registerReferenceProvider(LUA_SELECTOR, {
        async provideReferences(document, position, _refContext) {
            const wordRange = document.getWordRangeAtPosition(position, /[\w.]+/);
            if (!wordRange)
                return [];
            const word = document.getText(wordRange);
            if (!word || word.length < 2)
                return [];
            // For dotted paths like luna.graphics.draw, search the full path
            // For simple identifiers, search just the word
            const searchTerm = word.includes(".") ? word : word;
            const locations = [];
            // Search across all .lua files in workspace
            const files = await vscode.workspace.findFiles("**/*.lua", "**/node_modules/**", 500);
            for (const fileUri of files) {
                try {
                    const doc = await vscode.workspace.openTextDocument(fileUri);
                    const text = doc.getText();
                    // Use analyzer for precise token-based search
                    const refs = analyzer.findReferencesInDocument(text, searchTerm);
                    for (const ref of refs) {
                        locations.push(new vscode.Location(fileUri, new vscode.Position(ref.line, ref.column)));
                    }
                    // For dotted paths, also do a string search since the tokenizer
                    // splits on dots
                    if (searchTerm.includes(".")) {
                        const escaped = searchTerm.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
                        const pattern = new RegExp(escaped, "g");
                        let match;
                        while ((match = pattern.exec(text)) !== null) {
                            const pos = doc.positionAt(match.index);
                            // Avoid duplicates
                            const isDuplicate = locations.some(loc => loc.uri.fsPath === fileUri.fsPath &&
                                loc.range.start.line === pos.line &&
                                loc.range.start.character === pos.character);
                            if (!isDuplicate) {
                                locations.push(new vscode.Location(fileUri, pos));
                            }
                        }
                    }
                }
                catch {
                    // Skip files that can't be opened
                }
            }
            return locations;
        },
    });
    context.subscriptions.push(provider);
}
//# sourceMappingURL=references.js.map