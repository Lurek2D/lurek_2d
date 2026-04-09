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
exports.packageZip = packageZip;
exports.packageWindows = packageWindows;
exports.packageLinux = packageLinux;
const vscode = __importStar(require("vscode"));
/**
 * Packages the game as a zip archive using the platform-appropriate script.
 */
function packageZip() {
    const terminal = getOrCreateTerminal("Luna Package");
    terminal.show();
    if (process.platform === "win32") {
        terminal.sendText("powershell -ExecutionPolicy Bypass -File tools/dist.ps1");
    }
    else {
        terminal.sendText("bash tools/dist.sh");
    }
}
/**
 * Packages for Windows using dist.ps1.
 */
function packageWindows() {
    const terminal = getOrCreateTerminal("Luna Package");
    terminal.show();
    terminal.sendText("powershell -ExecutionPolicy Bypass -File tools/dist.ps1");
}
/**
 * Packages for Linux/macOS using dist.sh.
 */
function packageLinux() {
    const terminal = getOrCreateTerminal("Luna Package");
    terminal.show();
    terminal.sendText("bash tools/dist.sh");
}
function getOrCreateTerminal(name) {
    const existing = vscode.window.terminals.find((t) => t.name === name);
    if (existing) {
        return existing;
    }
    return vscode.window.createTerminal(name);
}
//# sourceMappingURL=packaging.js.map