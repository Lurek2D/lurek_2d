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
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const luaParser_js_1 = require("../services/luaParser.js");
const LUA_SELECTOR = { scheme: 'file', language: 'lua' };
const analyzer = new luaParser_js_1.LuaDocumentAnalyzer();
/**
 * Registers the Lua diagnostics provider.
 * Runs 6 diagnostic rules on document open, save, and change (debounced).
 */
function register(context, apiData) {
    const collection = vscode.languages.createDiagnosticCollection('lurek');
    context.subscriptions.push(collection);
    const debounceTimers = new Map();
    const diagnose = (document) => {
        if (document.languageId !== 'lua')
            return;
        try {
            const text = document.getText();
            const info = analyzer.analyze(text);
            const diagnostics = [];
            diagnostics.push(...checkDeprecated(text, apiData));
            diagnostics.push(...checkColorRange(text));
            diagnostics.push(...checkUnusedRequire(text, info));
            checkAssetNotFound(text, document, diagnostics);
            diagnostics.push(...checkThreadRandom(text, info));
            diagnostics.push(...checkMissingCallback(text, document, info));
            diagnostics.push(...checkWrongEnumValue(text, apiData));
            diagnostics.push(...checkUnknownLunaFunc(text, apiData));
            checkConfLua(text, document, diagnostics);
            collection.set(document.uri, diagnostics);
        }
        catch {
            // Never throw from diagnostics — silently degrade
        }
    };
    const debouncedDiagnose = (document) => {
        const key = document.uri.toString();
        const existing = debounceTimers.get(key);
        if (existing)
            clearTimeout(existing);
        debounceTimers.set(key, setTimeout(() => {
            debounceTimers.delete(key);
            diagnose(document);
        }, 300));
    };
    context.subscriptions.push(vscode.workspace.onDidOpenTextDocument(diagnose), vscode.workspace.onDidSaveTextDocument(diagnose), vscode.workspace.onDidChangeTextDocument((e) => debouncedDiagnose(e.document)), vscode.workspace.onDidCloseTextDocument((doc) => {
        collection.delete(doc.uri);
        const key = doc.uri.toString();
        const timer = debounceTimers.get(key);
        if (timer) {
            clearTimeout(timer);
            debounceTimers.delete(key);
        }
    }));
    // Diagnose already-open documents
    for (const doc of vscode.workspace.textDocuments) {
        diagnose(doc);
    }
}
// ── Rule 1: lurek.deprecated ──────────────────────────────────
function checkDeprecated(text, apiData) {
    const diagnostics = [];
    const deprecatedFns = apiData.getAllFunctions().filter(f => f.deprecated);
    if (deprecatedFns.length === 0)
        return diagnostics;
    const lines = text.split('\n');
    for (const fn of deprecatedFns) {
        const escaped = fn.fullPath.replace(/\./g, '\\.');
        const regex = new RegExp(escaped, 'g');
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line.trimStart().startsWith('--'))
                continue;
            let match;
            while ((match = regex.exec(line)) !== null) {
                const range = new vscode.Range(i, match.index, i, match.index + fn.fullPath.length);
                const diag = new vscode.Diagnostic(range, `${fn.fullPath} is deprecated. ${fn.deprecated}`, vscode.DiagnosticSeverity.Warning);
                diag.code = 'lurek.deprecated';
                diag.source = 'Luna Toolkit';
                diag.tags = [vscode.DiagnosticTag.Deprecated];
                diagnostics.push(diag);
            }
        }
    }
    return diagnostics;
}
// ── Rule 2: lurek.colorRange ──────────────────────────────────
function checkColorRange(text) {
    const diagnostics = [];
    const lines = text.split('\n');
    const colorFuncPattern = /lurek\.graphics\.(?:setColor|setBackgroundColor|clear)\s*\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)(?:\s*,\s*([\d.]+))?\s*\)/g;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.trimStart().startsWith('--'))
            continue;
        let match;
        while ((match = colorFuncPattern.exec(line)) !== null) {
            const vals = [parseFloat(match[1]), parseFloat(match[2]), parseFloat(match[3])];
            if (match[4] !== undefined)
                vals.push(parseFloat(match[4]));
            const hasLargeValue = vals.some(v => v > 1.0);
            if (!hasLargeValue)
                continue;
            const converted = vals.slice(0, 3).map(v => (v / 255).toFixed(2));
            const range = new vscode.Range(i, match.index, i, match.index + match[0].length);
            const diag = new vscode.Diagnostic(range, `Color values should be in 0-1 range. Did you mean ${converted.join(', ')}?`, vscode.DiagnosticSeverity.Warning);
            diag.code = 'lurek.colorRange';
            diag.source = 'Luna Toolkit';
            diagnostics.push(diag);
        }
    }
    return diagnostics;
}
// ── Rule 3: lurek.unusedRequire ────────────────────────────────
function checkUnusedRequire(text, info) {
    const diagnostics = [];
    for (const req of info.requires) {
        const varName = req.localName;
        const refs = analyzer.findReferencesInDocument(text, varName);
        // One reference is the declaration itself
        if (refs.length <= 1) {
            const lines = text.split('\n');
            const lineIdx = req.line;
            const lineText = lines[lineIdx] ?? '';
            const range = new vscode.Range(lineIdx, 0, lineIdx, lineText.length);
            const diag = new vscode.Diagnostic(range, `Required module '${varName}' is never used`, vscode.DiagnosticSeverity.Hint);
            diag.code = 'lurek.unusedRequire';
            diag.source = 'Luna Toolkit';
            diag.tags = [vscode.DiagnosticTag.Unnecessary];
            diagnostics.push(diag);
        }
    }
    return diagnostics;
}
// ── Rule 4: lurek.assetNotFound ────────────────────────────────
function checkAssetNotFound(text, document, diagnostics) {
    if (!vscode.workspace.workspaceFolders?.length)
        return;
    const lines = text.split('\n');
    const assetFuncPattern = /lurek\.(?:graphics\.newImage|audio\.newSource|filesystem\.read)\s*\(\s*["']([^"']+)["']/g;
    const docDir = path.dirname(document.uri.fsPath);
    const wsRoot = vscode.workspace.workspaceFolders[0].uri.fsPath;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.trimStart().startsWith('--'))
            continue;
        let match;
        while ((match = assetFuncPattern.exec(line)) !== null) {
            const assetPath = match[1];
            // Skip URLs and extension-less paths (likely module names)
            if (assetPath.includes('://') || !assetPath.includes('.'))
                continue;
            const candidates = [
                path.resolve(docDir, assetPath),
                path.resolve(wsRoot, assetPath),
            ];
            const exists = candidates.some(c => {
                try {
                    return fs.existsSync(c);
                }
                catch {
                    return false;
                }
            });
            if (!exists) {
                const strStart = line.indexOf(assetPath, match.index);
                const range = new vscode.Range(i, strStart, i, strStart + assetPath.length);
                const diag = new vscode.Diagnostic(range, `Asset file '${assetPath}' not found in workspace`, vscode.DiagnosticSeverity.Warning);
                diag.code = 'lurek.assetNotFound';
                diag.source = 'Luna Toolkit';
                diagnostics.push(diag);
            }
        }
    }
}
// ── Rule 5: lurek.threadRandom ────────────────────────────────
function checkThreadRandom(text, info) {
    const diagnostics = [];
    if (!text.includes('lurek.thread'))
        return diagnostics;
    const lines = text.split('\n');
    const randomPattern = /\bmath\.random\s*\(/g;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.trimStart().startsWith('--'))
            continue;
        let match;
        while ((match = randomPattern.exec(line)) !== null) {
            const scope = analyzer.getScopeAt(info, i);
            if (!scope)
                continue;
            // Heuristic: check if surrounding scope contains thread-related code
            const scopeLines = lines.slice(scope.startLine, scope.endLine + 1).join('\n');
            if (!scopeLines.includes('lurek.thread'))
                continue;
            const range = new vscode.Range(i, match.index, i, match.index + 'math.random'.length);
            const diag = new vscode.Diagnostic(range, 'math.random in threads may produce identical sequences. Consider seeding with thread ID.', vscode.DiagnosticSeverity.Information);
            diag.code = 'lurek.threadRandom';
            diag.source = 'Luna Toolkit';
            diagnostics.push(diag);
        }
    }
    return diagnostics;
}
// ── Rule 6: lurek.missingCallback ─────────────────────────────
function checkMissingCallback(text, document, info) {
    const diagnostics = [];
    const fileName = path.basename(document.uri.fsPath);
    // Only for files named main.lua
    if (fileName !== 'main.lua')
        return diagnostics;
    const hasUpdate = info.callbacks.some(cb => cb.name === 'update')
        || /lurek\.update\s*=\s*function/.test(text);
    const hasDraw = info.callbacks.some(cb => cb.name === 'draw')
        || /lurek\.draw\s*=\s*function/.test(text);
    if (!hasUpdate && !hasDraw) {
        const lines = text.split('\n');
        const range = new vscode.Range(0, 0, 0, lines[0]?.length ?? 0);
        const diag = new vscode.Diagnostic(range, 'main.lua should define lurek.update(dt) and/or lurek.draw()', vscode.DiagnosticSeverity.Information);
        diag.code = 'lurek.missingCallback';
        diag.source = 'Luna Toolkit';
        diagnostics.push(diag);
    }
    return diagnostics;
}
// ── D2: Wrong enum value with "Did you mean?" ─────────────────
// Known enum sets per function/param pattern
const ENUM_RULES = [
    {
        pattern: /lurek\.graphics\.(?:rectangle|circle|arc|polygon|ellipse)\s*\(\s*["']([^"']+)["']/g,
        valid: ['fill', 'line'],
        label: 'draw mode',
    },
    {
        pattern: /lurek\.graphics\.setBlendMode\s*\(\s*["']([^"']+)["']/g,
        valid: ['alpha', 'add', 'subtract', 'multiply', 'replace', 'screen', 'darken', 'lighten', 'none'],
        label: 'blend mode',
    },
    {
        pattern: /lurek\.graphics\.setLineStyle\s*\(\s*["']([^"']+)["']/g,
        valid: ['smooth', 'rough'],
        label: 'line style',
    },
    {
        pattern: /lurek\.graphics\.setFilter\s*\([^,]*,\s*["']([^"']+)["']/g,
        valid: ['linear', 'nearest'],
        label: 'texture filter',
    },
    {
        pattern: /lurek\.graphics\.setFilter\s*\(\s*["']([^"']+)["']/g,
        valid: ['linear', 'nearest'],
        label: 'texture filter',
    },
    {
        pattern: /lurek\.audio\.newSource\s*\([^,]*,\s*["']([^"']+)["']/g,
        valid: ['static', 'stream'],
        label: 'audio source type',
    },
    {
        pattern: /lurek\.physics\.newBody\s*\([^,]*,[^,]*,[^,]*,\s*["']([^"']+)["']/g,
        valid: ['dynamic', 'static', 'kinematic'],
        label: 'body type',
    },
    {
        pattern: /lurek\.graphics\.printf\s*\([^)]*,[^)]*,[^)]*,[^)]*,\s*["']([^"']+)["']/g,
        valid: ['left', 'center', 'right', 'justify'],
        label: 'text alignment',
    },
];
function fuzzyMatch(word, candidates) {
    // Simple edit-distance-1 check
    for (const c of candidates) {
        if (c === word)
            return undefined; // exact match — no error
        if (Math.abs(c.length - word.length) <= 2) {
            let diff = 0;
            const len = Math.max(c.length, word.length);
            for (let i = 0; i < len; i++) {
                if ((c[i] ?? '') !== (word[i] ?? ''))
                    diff++;
            }
            if (diff <= 2)
                return c;
        }
    }
    return undefined;
}
function checkWrongEnumValue(text, _apiData) {
    const diagnostics = [];
    const lines = text.split('\n');
    for (const rule of ENUM_RULES) {
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (line.trimStart().startsWith('--'))
                continue;
            rule.pattern.lastIndex = 0;
            let m;
            while ((m = rule.pattern.exec(line)) !== null) {
                const value = m[1];
                if (rule.valid.includes(value))
                    continue;
                const suggestion = fuzzyMatch(value, rule.valid);
                const valueStart = line.indexOf(`"${value}"`, m.index) !== -1
                    ? line.indexOf(`"${value}"`, m.index) + 1
                    : line.indexOf(`'${value}'`, m.index) + 1;
                const range = new vscode.Range(i, valueStart, i, valueStart + value.length);
                const msg = suggestion
                    ? `Unknown ${rule.label} "${value}". Did you mean "${suggestion}"? Valid: ${rule.valid.join(', ')}`
                    : `Unknown ${rule.label} "${value}". Valid values: ${rule.valid.join(', ')}`;
                const diag = new vscode.Diagnostic(range, msg, vscode.DiagnosticSeverity.Warning);
                diag.code = 'lurek.wrongEnumValue';
                diag.source = 'Luna Toolkit';
                diagnostics.push(diag);
            }
        }
    }
    return diagnostics;
}
// ── D6: Unknown lurek.module.function call ─────────────────────
function checkUnknownLunaFunc(text, apiData) {
    const diagnostics = [];
    const lines = text.split('\n');
    const callPattern = /lurek\.(\w+)\.(\w+)\s*\(/g;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.trimStart().startsWith('--'))
            continue;
        callPattern.lastIndex = 0;
        let m;
        while ((m = callPattern.exec(line)) !== null) {
            const modName = m[1];
            const funcName = m[2];
            const fullPath = `lurek.${modName}.${funcName}`;
            const mod = apiData.getModule(modName);
            if (!mod)
                continue; // unknown module — skip (not our concern)
            const knownFn = apiData.getFunction(fullPath);
            if (knownFn)
                continue; // known function
            // Also check methods (e.g. for known types)
            const methodFn = apiData.getFunctions(modName).find(f => f.name === funcName);
            if (methodFn)
                continue;
            const col = m.index + `lurek.${modName}.`.length;
            const range = new vscode.Range(i, col, i, col + funcName.length);
            const diag = new vscode.Diagnostic(range, `"${funcName}" is not a known function in lurek.${modName}`, vscode.DiagnosticSeverity.Warning);
            diag.code = 'lurek.unknownFunction';
            diag.source = 'Luna Toolkit';
            diagnostics.push(diag);
        }
    }
    return diagnostics;
}
// ── D5: conf.lua validation ───────────────────────────────────
const VALID_CONF_KEYS = {
    window: ['title', 'width', 'height', 'vsync', 'fullscreen', 'resizable',
        'highdpi', 'minwidth', 'minheight', 'x', 'y', 'borderless',
        'displayindex', 'icon'],
    performance: ['target_fps', 'fixed_dt'],
    modules: ['physics', 'audio', 'graphics', 'input', 'timer', 'filesystem',
        'math', 'thread'],
    log: ['file', 'append', 'level'],
};
function checkConfLua(text, document, diagnostics) {
    if (path.basename(document.uri.fsPath) !== 'conf.lua')
        return;
    const lines = text.split('\n');
    const keyPattern = /\bt\.(\w+)\.(\w+)\s*=/g;
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.trimStart().startsWith('--'))
            continue;
        keyPattern.lastIndex = 0;
        let m;
        while ((m = keyPattern.exec(line)) !== null) {
            const section = m[1];
            const key = m[2];
            const validKeys = VALID_CONF_KEYS[section];
            if (!validKeys)
                continue; // unknown section — skip
            if (validKeys.includes(key))
                continue;
            const col = m.index + `t.${section}.`.length;
            const range = new vscode.Range(i, col, i, col + key.length);
            const diag = new vscode.Diagnostic(range, `"${key}" is not a recognised conf.lua key in t.${section}. Valid: ${validKeys.join(', ')}`, vscode.DiagnosticSeverity.Warning);
            diag.code = 'lurek.confKey';
            diag.source = 'Luna Toolkit';
            diagnostics.push(diag);
        }
    }
}
//# sourceMappingURL=diagnostics.js.map