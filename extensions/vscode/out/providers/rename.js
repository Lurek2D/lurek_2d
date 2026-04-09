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
const LUA_SELECTOR = { scheme: 'file', language: 'lua' };
const analyzer = new luaParser_js_1.LuaDocumentAnalyzer();
const LUA_KEYWORDS = new Set([
    'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for',
    'function', 'goto', 'if', 'in', 'local', 'nil', 'not', 'or',
    'repeat', 'return', 'then', 'true', 'until', 'while',
]);
/**
 * Registers the rename provider for Lua files.
 */
function register(context, apiData) {
    context.subscriptions.push(vscode.languages.registerRenameProvider(LUA_SELECTOR, {
        prepareRename(document, position) {
            try {
                return doPrepareRename(document, position, apiData);
            }
            catch {
                return undefined;
            }
        },
        provideRenameEdits(document, position, newName) {
            try {
                return doRename(document, position, newName, apiData);
            }
            catch {
                return undefined;
            }
        },
    }));
}
// ── Prepare rename ───────────────────────────────────────────
function doPrepareRename(document, position, apiData) {
    const text = document.getText();
    const line = position.line;
    const col = position.character;
    // Don't rename inside strings or comments
    if (analyzer.isInsideString(text, line, col) || analyzer.isInsideComment(text, line, col)) {
        return undefined;
    }
    const word = getWordAt(document, position);
    if (!word)
        return undefined;
    // Don't rename Lua keywords
    if (LUA_KEYWORDS.has(word.text)) {
        return undefined;
    }
    // Don't rename luna.* API names
    if (isLunaApiName(document, position, word.text, apiData)) {
        return undefined;
    }
    return { range: word.range, placeholder: word.text };
}
// ── Rename execution ─────────────────────────────────────────
function doRename(document, position, newName, apiData) {
    const text = document.getText();
    const line = position.line;
    const col = position.character;
    if (analyzer.isInsideString(text, line, col) || analyzer.isInsideComment(text, line, col)) {
        return undefined;
    }
    const word = getWordAt(document, position);
    if (!word || LUA_KEYWORDS.has(word.text))
        return undefined;
    if (isLunaApiName(document, position, word.text, apiData))
        return undefined;
    const symbolName = word.text;
    const info = analyzer.analyze(text);
    // Find the symbol definition to determine scope
    const defSymbol = info.symbols.find(s => s.name === symbolName && (s.kind === 'local' || s.kind === 'function' || s.kind === 'parameter'));
    // Determine the scope range for local/parameter symbols
    let scopeStartLine = 0;
    let scopeEndLine = document.lineCount - 1;
    if (defSymbol?.isLocal && defSymbol.scope) {
        const parentScope = info.scopes.find(sc => sc.name === defSymbol.scope);
        if (parentScope) {
            scopeStartLine = parentScope.startLine;
            scopeEndLine = parentScope.endLine;
        }
    }
    else if (defSymbol?.kind === 'parameter' && defSymbol.scope) {
        const funcScope = info.scopes.find(sc => sc.name === defSymbol.scope);
        if (funcScope) {
            scopeStartLine = funcScope.startLine;
            scopeEndLine = funcScope.endLine;
        }
    }
    // Find all identifier tokens matching the symbol name
    const tokens = analyzer.tokenize(text);
    const edit = new vscode.WorkspaceEdit();
    for (const tok of tokens) {
        if (tok.type !== luaParser_js_1.TokenType.Identifier)
            continue;
        if (tok.value !== symbolName)
            continue;
        if (tok.line < scopeStartLine || tok.line > scopeEndLine)
            continue;
        // Skip occurrences inside strings/comments
        if (analyzer.isInsideString(text, tok.line, tok.column))
            continue;
        if (analyzer.isInsideComment(text, tok.line, tok.column))
            continue;
        // Verify word boundary: the character before/after must not be an identifier char
        const lineText = document.lineAt(tok.line).text;
        const before = tok.column > 0 ? lineText[tok.column - 1] : '';
        const after = tok.column + tok.length < lineText.length ? lineText[tok.column + tok.length] : '';
        if (isIdentChar(before) || isIdentChar(after))
            continue;
        const range = new vscode.Range(tok.line, tok.column, tok.line, tok.column + tok.length);
        edit.replace(document.uri, range, newName);
    }
    return edit;
}
function getWordAt(document, position) {
    const range = document.getWordRangeAtPosition(position, /[a-zA-Z_]\w*/);
    if (!range)
        return undefined;
    return { text: document.getText(range), range };
}
function isLunaApiName(document, position, word, apiData) {
    const lineText = document.lineAt(position.line).text;
    const wordStart = position.character;
    // Check if preceded by `luna.` or `luna.xxx.`
    const beforeWord = lineText.substring(0, wordStart);
    if (/luna\.\w*\.?$/.test(beforeWord)) {
        // Check if it's a known API function
        const fn = apiData.getAllFunctions().find(f => f.name === word);
        if (fn)
            return true;
    }
    // `luna` itself
    if (word === 'luna') {
        return true;
    }
    return false;
}
function isIdentChar(ch) {
    return /[a-zA-Z0-9_]/.test(ch);
}
//# sourceMappingURL=rename.js.map