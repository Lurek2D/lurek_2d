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
const LUA_SELECTOR = { scheme: 'file', language: 'lua' };
/** Color-related function names to detect. */
const COLOR_FUNCTIONS = ['setColor', 'setBackgroundColor', 'clear', 'newColor'];
/**
 * Registers the color provider for luna.graphics color calls.
 * Detects 0-1 range RGBA values and shows the VS Code color picker.
 */
function register(context, apiData) {
    const provider = vscode.languages.registerColorProvider(LUA_SELECTOR, {
        provideDocumentColors(document) {
            try {
                return detectColors(document);
            }
            catch {
                return [];
            }
        },
        provideColorPresentations(color, colorContext) {
            try {
                return createPresentations(color, colorContext);
            }
            catch {
                return [];
            }
        },
    });
    context.subscriptions.push(provider);
}
/** Build regex pattern for all color functions. */
const COLOR_CALL_PATTERN = new RegExp(`luna\\.graphics\\.(?:${COLOR_FUNCTIONS.join('|')})` +
    `\\s*\\(\\s*([\\d.]+)\\s*,\\s*([\\d.]+)\\s*,\\s*([\\d.]+)(?:\\s*,\\s*([\\d.]+))?\\s*\\)`, 'g');
function detectColors(document) {
    const colors = [];
    const text = document.getText();
    const pattern = new RegExp(COLOR_CALL_PATTERN.source, 'g');
    let match;
    while ((match = pattern.exec(text)) !== null) {
        const r = parseFloat(match[1]);
        const g = parseFloat(match[2]);
        const b = parseFloat(match[3]);
        const a = match[4] !== undefined ? parseFloat(match[4]) : 1;
        // Only provide inline color for 0-1 range values
        if (r > 1 || g > 1 || b > 1 || a > 1)
            continue;
        // Find the range of just the arguments (r, g, b[, a])
        const fullMatchText = match[0];
        const argsStart = fullMatchText.indexOf('(') + 1;
        const argsEnd = fullMatchText.lastIndexOf(')');
        const argsOffset = match.index + argsStart;
        const argsLen = argsEnd - argsStart;
        const startPos = document.positionAt(argsOffset);
        const endPos = document.positionAt(argsOffset + argsLen);
        const range = new vscode.Range(startPos, endPos);
        colors.push(new vscode.ColorInformation(range, new vscode.Color(r, g, b, a)));
    }
    return colors;
}
function createPresentations(color, colorContext) {
    const r = formatComponent(color.red);
    const g = formatComponent(color.green);
    const b = formatComponent(color.blue);
    const a = formatComponent(color.alpha);
    const presentations = [];
    // With alpha
    const withAlpha = new vscode.ColorPresentation(`${r}, ${g}, ${b}, ${a}`);
    withAlpha.textEdit = new vscode.TextEdit(colorContext.range, `${r}, ${g}, ${b}, ${a}`);
    presentations.push(withAlpha);
    // Without alpha (if alpha is ~1)
    if (Math.abs(color.alpha - 1.0) < 0.005) {
        const noAlpha = new vscode.ColorPresentation(`${r}, ${g}, ${b}`);
        noAlpha.textEdit = new vscode.TextEdit(colorContext.range, `${r}, ${g}, ${b}`);
        presentations.push(noAlpha);
    }
    // Hex comment
    const hexR = Math.round(color.red * 255).toString(16).padStart(2, '0');
    const hexG = Math.round(color.green * 255).toString(16).padStart(2, '0');
    const hexB = Math.round(color.blue * 255).toString(16).padStart(2, '0');
    const hexPresentation = new vscode.ColorPresentation(`${r}, ${g}, ${b} --[[ #${hexR}${hexG}${hexB} ]]`);
    hexPresentation.textEdit = new vscode.TextEdit(colorContext.range, `${r}, ${g}, ${b} --[[ #${hexR}${hexG}${hexB} ]]`);
    presentations.push(hexPresentation);
    return presentations;
}
/** Format a 0-1 color component to 2 decimal places, trimming trailing zeros. */
function formatComponent(value) {
    return value.toFixed(2).replace(/\.?0+$/, '') || '0';
}
//# sourceMappingURL=color.js.map