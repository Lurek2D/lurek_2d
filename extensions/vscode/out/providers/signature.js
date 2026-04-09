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
// ── Helpers ──────────────────────────────────────────────────
function buildSignatureInfo(fn) {
    const sig = new vscode.SignatureInformation(fn.signature);
    sig.documentation = new vscode.MarkdownString(fn.description);
    sig.parameters = fn.parameters.map(p => {
        const paramDoc = new vscode.MarkdownString();
        const opt = p.optional ? " *(optional)*" : "";
        const def = p.default ? ` — default: \`${p.default}\`` : "";
        paramDoc.appendMarkdown(`*${p.type}*${opt}${def}`);
        if (p.description)
            paramDoc.appendMarkdown(` — ${p.description}`);
        return new vscode.ParameterInformation(p.name, paramDoc);
    });
    return sig;
}
function countActiveParam(argsText) {
    let paramIndex = 0;
    let parenDepth = 0;
    let bracketDepth = 0;
    let braceDepth = 0;
    let inString = false;
    let stringChar = "";
    for (let i = 0; i < argsText.length; i++) {
        const ch = argsText[i];
        // Handle string literals
        if (inString) {
            if (ch === "\\" && i + 1 < argsText.length) {
                i++;
                continue;
            }
            if (ch === stringChar)
                inString = false;
            continue;
        }
        if (ch === '"' || ch === "'") {
            inString = true;
            stringChar = ch;
            continue;
        }
        // Handle nesting
        if (ch === "(") {
            parenDepth++;
            continue;
        }
        if (ch === ")") {
            parenDepth--;
            continue;
        }
        if (ch === "[") {
            bracketDepth++;
            continue;
        }
        if (ch === "]") {
            bracketDepth--;
            continue;
        }
        if (ch === "{") {
            braceDepth++;
            continue;
        }
        if (ch === "}") {
            braceDepth--;
            continue;
        }
        // Count commas at top level only
        if (ch === "," && parenDepth === 0 && bracketDepth === 0 && braceDepth === 0) {
            paramIndex++;
        }
    }
    return paramIndex;
}
// ── Provider registration ────────────────────────────────────
function register(context, apiData) {
    const provider = vscode.languages.registerSignatureHelpProvider(LUA_SELECTOR, {
        provideSignatureHelp(document, position) {
            const text = document.getText();
            // Use the analyzer to find what function call we're inside
            const callCtx = analyzer.getFunctionCallContext(text, position.line, position.character);
            if (!callCtx)
                return undefined;
            const { functionName, paramIndex } = callCtx;
            let fn;
            // ── Luna2D API functions ──
            fn = apiData.getFunction(functionName);
            // ── Method calls (obj:method) — try to find in all methods ──
            if (!fn && functionName.includes(":")) {
                const colonIdx = functionName.lastIndexOf(":");
                const methodName = functionName.slice(colonIdx + 1);
                // Search all methods
                for (const apiFn of apiData.getAllFunctions()) {
                    if (apiFn.isMethod && apiFn.name === methodName) {
                        fn = apiFn;
                        break;
                    }
                }
            }
            // ── Lua stdlib functions ──
            if (!fn) {
                const stdlib = apiData.getLuaStdlib("luajit");
                fn = stdlib.find(f => f.fullPath === functionName);
            }
            if (!fn || fn.parameters.length === 0)
                return undefined;
            const sig = buildSignatureInfo(fn);
            const help = new vscode.SignatureHelp();
            help.signatures = [sig];
            help.activeSignature = 0;
            help.activeParameter = Math.min(paramIndex, fn.parameters.length - 1);
            return help;
        },
    }, "(", ",");
    context.subscriptions.push(provider);
}
//# sourceMappingURL=signature.js.map