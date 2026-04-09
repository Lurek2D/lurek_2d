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
 * Registers the inlay hints provider for luna.* function calls.
 * Shows parameter name hints at call sites.
 */
function register(context, apiData) {
    const provider = vscode.languages.registerInlayHintsProvider(LUA_SELECTOR, {
        provideInlayHints(document, range) {
            try {
                const config = vscode.workspace.getConfiguration('luna');
                if (config.get('inlayHints.enabled') === false)
                    return [];
                return getInlayHints(document, range, apiData);
            }
            catch {
                return [];
            }
        },
    });
    context.subscriptions.push(provider);
}
function getInlayHints(document, range, apiData) {
    const hints = [];
    const text = document.getText(range);
    const offset = document.offsetAt(range.start);
    // Match luna.module.func(...) calls — handle nested parens by finding the call then parsing args
    const callPattern = /(luna\.\w+\.\w+)\s*\(/g;
    let callMatch;
    while ((callMatch = callPattern.exec(text)) !== null) {
        const fullPath = callMatch[1];
        const fn = apiData.getFunction(fullPath);
        if (!fn || fn.parameters.length === 0)
            continue;
        // Find the opening paren position
        const openParenIdx = callMatch.index + callMatch[0].length - 1;
        const argsText = extractArgsText(text, openParenIdx);
        if (!argsText)
            continue;
        const args = splitArgs(argsText);
        // Don't show hints for single-argument calls
        if (args.length <= 1)
            continue;
        // Calculate the absolute offset of the arguments start
        const argsStartOffset = offset + openParenIdx + 1;
        let argOffset = argsStartOffset;
        for (let i = 0; i < args.length && i < fn.parameters.length; i++) {
            const arg = args[i];
            const trimmedArg = arg.trimStart();
            const leadingSpaces = arg.length - trimmedArg.length;
            // Skip if argument is a named assignment (e.g., "x = 5")
            if (/^\w+\s*=/.test(trimmedArg)) {
                argOffset += arg.length + 1;
                continue;
            }
            const param = fn.parameters[i];
            // Skip if argument variable name matches the parameter name
            if (trimmedArg === param.name) {
                argOffset += arg.length + 1;
                continue;
            }
            // Skip obvious string/boolean literals where context is clear
            if (shouldSkipHint(trimmedArg, param.name)) {
                argOffset += arg.length + 1;
                continue;
            }
            const pos = document.positionAt(argOffset + leadingSpaces);
            const hint = new vscode.InlayHint(pos, `${param.name}:`, vscode.InlayHintKind.Parameter);
            hint.paddingRight = true;
            hints.push(hint);
            argOffset += arg.length + 1; // +1 for comma
        }
    }
    return hints;
}
/**
 * Extract the text between matching parentheses starting at openParenIdx.
 */
function extractArgsText(text, openParenIdx) {
    if (text[openParenIdx] !== '(')
        return undefined;
    let depth = 1;
    let pos = openParenIdx + 1;
    while (pos < text.length && depth > 0) {
        const ch = text[pos];
        if (ch === '(')
            depth++;
        else if (ch === ')')
            depth--;
        pos++;
    }
    if (depth !== 0)
        return undefined;
    return text.slice(openParenIdx + 1, pos - 1);
}
/**
 * Split function arguments by commas, respecting nested parens/brackets/braces/strings.
 */
function splitArgs(argsText) {
    if (!argsText.trim())
        return [];
    const args = [];
    let current = '';
    let depth = 0;
    let inString = null;
    for (let i = 0; i < argsText.length; i++) {
        const ch = argsText[i];
        // Handle escape sequences inside strings
        if (inString && ch === '\\') {
            current += ch;
            if (i + 1 < argsText.length) {
                current += argsText[i + 1];
                i++;
            }
            continue;
        }
        // String boundaries
        if (!inString && (ch === '"' || ch === "'")) {
            inString = ch;
            current += ch;
            continue;
        }
        if (inString && ch === inString) {
            inString = null;
            current += ch;
            continue;
        }
        if (inString) {
            current += ch;
            continue;
        }
        if (ch === '(' || ch === '{' || ch === '[') {
            depth++;
            current += ch;
        }
        else if (ch === ')' || ch === '}' || ch === ']') {
            depth--;
            current += ch;
        }
        else if (ch === ',' && depth === 0) {
            args.push(current);
            current = '';
        }
        else {
            current += ch;
        }
    }
    if (current)
        args.push(current);
    return args;
}
/**
 * Determine if a hint should be skipped for a given argument.
 * Skip for obvious boolean/string literals where the parameter intent is clear.
 */
function shouldSkipHint(arg, paramName) {
    // Skip if the argument is true/false and param name suggests boolean
    if ((arg === 'true' || arg === 'false' || arg === 'nil') && paramName.length <= 4) {
        return true;
    }
    return false;
}
//# sourceMappingURL=inlayHints.js.map