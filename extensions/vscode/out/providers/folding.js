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
/**
 * Registers the code folding provider for Lua files.
 */
function register(context, _apiData) {
    context.subscriptions.push(vscode.languages.registerFoldingRangeProvider(LUA_SELECTOR, {
        provideFoldingRanges(document) {
            try {
                return computeFoldingRanges(document);
            }
            catch {
                return [];
            }
        },
    }));
}
function computeFoldingRanges(document) {
    const text = document.getText();
    const tokens = analyzer.tokenize(text);
    const ranges = [];
    // Stack for keyword-based blocks
    const stack = [];
    // Track multiline comments and strings from tokens
    addTokenFolds(tokens, ranges);
    // Track region markers and consecutive doc comments from lines
    addLineFolds(document, ranges);
    // Non-whitespace, non-comment, non-string tokens for block analysis
    const codeToks = tokens.filter(t => t.type !== luaParser_js_1.TokenType.Whitespace &&
        t.type !== luaParser_js_1.TokenType.Comment &&
        t.type !== luaParser_js_1.TokenType.String &&
        t.type !== luaParser_js_1.TokenType.EOF);
    // Track `{` / `}` for table constructors
    const braceStack = [];
    for (const tok of codeToks) {
        if (tok.type === luaParser_js_1.TokenType.Keyword) {
            switch (tok.value) {
                case 'function':
                case 'if':
                case 'for':
                case 'while':
                case 'do':
                    stack.push({ keyword: tok.value, line: tok.line, kind: vscode.FoldingRangeKind.Region });
                    break;
                case 'repeat':
                    stack.push({ keyword: 'repeat', line: tok.line, kind: vscode.FoldingRangeKind.Region });
                    break;
                case 'end': {
                    const entry = popMatching(stack, ['function', 'if', 'for', 'while', 'do']);
                    if (entry && tok.line > entry.line) {
                        ranges.push(new vscode.FoldingRange(entry.line, tok.line, entry.kind));
                    }
                    break;
                }
                case 'until': {
                    const entry = popMatching(stack, ['repeat']);
                    if (entry && tok.line > entry.line) {
                        ranges.push(new vscode.FoldingRange(entry.line, tok.line, entry.kind));
                    }
                    break;
                }
            }
        }
        if (tok.type === luaParser_js_1.TokenType.Punctuation) {
            if (tok.value === '{') {
                braceStack.push(tok.line);
            }
            else if (tok.value === '}') {
                const openLine = braceStack.pop();
                if (openLine !== undefined && tok.line > openLine) {
                    ranges.push(new vscode.FoldingRange(openLine, tok.line, vscode.FoldingRangeKind.Region));
                }
            }
        }
    }
    return ranges;
}
// ── Token-based folds (multiline comments & long strings) ────
function addTokenFolds(tokens, ranges) {
    for (const tok of tokens) {
        if (tok.type === luaParser_js_1.TokenType.Comment && tok.value.startsWith('--[')) {
            const nlCount = countNewlines(tok.value);
            if (nlCount > 0) {
                ranges.push(new vscode.FoldingRange(tok.line, tok.line + nlCount, vscode.FoldingRangeKind.Comment));
            }
        }
        if (tok.type === luaParser_js_1.TokenType.String && tok.value.startsWith('[')) {
            const nlCount = countNewlines(tok.value);
            if (nlCount > 0) {
                ranges.push(new vscode.FoldingRange(tok.line, tok.line + nlCount, vscode.FoldingRangeKind.Region));
            }
        }
    }
}
// ── Line-based folds (regions, consecutive doc comments) ─────
function addLineFolds(document, ranges) {
    const regionStack = [];
    let docCommentStart;
    let lastDocCommentLine = -2;
    for (let i = 0; i < document.lineCount; i++) {
        const line = document.lineAt(i).text.trimStart();
        // -- region / -- endregion markers
        if (/^--\s*region\b/i.test(line)) {
            regionStack.push(i);
        }
        else if (/^--\s*endregion\b/i.test(line)) {
            const start = regionStack.pop();
            if (start !== undefined && i > start) {
                ranges.push(new vscode.FoldingRange(start, i, vscode.FoldingRangeKind.Region));
            }
        }
        // Consecutive `---` doc comments
        if (/^---/.test(line) && !line.startsWith('---[')) {
            if (i === lastDocCommentLine + 1) {
                // continue the run
            }
            else {
                // flush previous run
                flushDocCommentRun(docCommentStart, lastDocCommentLine, ranges);
                docCommentStart = i;
            }
            lastDocCommentLine = i;
        }
    }
    // flush final run
    flushDocCommentRun(docCommentStart, lastDocCommentLine, ranges);
}
function flushDocCommentRun(start, end, ranges) {
    if (start !== undefined && end > start) {
        ranges.push(new vscode.FoldingRange(start, end, vscode.FoldingRangeKind.Comment));
    }
}
// ── Helpers ──────────────────────────────────────────────────
function popMatching(stack, keywords) {
    for (let i = stack.length - 1; i >= 0; i--) {
        if (keywords.includes(stack[i].keyword)) {
            return stack.splice(i, 1)[0];
        }
    }
    return undefined;
}
function countNewlines(text) {
    let count = 0;
    for (const ch of text) {
        if (ch === '\n')
            count++;
    }
    return count;
}
//# sourceMappingURL=folding.js.map