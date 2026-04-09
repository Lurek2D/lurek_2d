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
exports.registerDebugBridgeCommands = registerDebugBridgeCommands;
const vscode = __importStar(require("vscode"));
/**
 * Registers debug bridge commands that interact with a running Luna2D engine.
 */
function registerDebugBridgeCommands(context, bridge) {
    // ── luna.debug.connect ───────────────────────────────────
    context.subscriptions.push(vscode.commands.registerCommand("luna.debug.connect", async () => {
        if (bridge.isConnected) {
            vscode.window.showInformationMessage("Already connected to Luna2D engine.");
            return;
        }
        const portStr = await vscode.window.showInputBox({
            prompt: "Debug bridge port",
            value: String(vscode.workspace.getConfiguration("luna.debugBridge").get("port", 19740)),
            validateInput: (v) => {
                const n = Number(v);
                if (isNaN(n) || n < 1024 || n > 65535) {
                    return "Port must be 1024–65535";
                }
                return undefined;
            },
        });
        if (portStr === undefined) {
            return; // cancelled
        }
        bridge.showOutput();
        const ok = await bridge.connect(Number(portStr));
        if (ok) {
            vscode.window.showInformationMessage("Connected to Luna2D engine.");
            vscode.commands.executeCommand("setContext", "luna.debugConnected", true);
        }
        else {
            vscode.window.showErrorMessage("Failed to connect. Is the engine running with debug bridge enabled?");
        }
    }));
    // ── luna.debug.disconnect ────────────────────────────────
    context.subscriptions.push(vscode.commands.registerCommand("luna.debug.disconnect", () => {
        bridge.disconnect();
        vscode.commands.executeCommand("setContext", "luna.debugConnected", false);
        vscode.window.showInformationMessage("Disconnected from Luna2D engine.");
    }));
    // ── luna.debug.evaluate ──────────────────────────────────
    context.subscriptions.push(vscode.commands.registerCommand("luna.debug.evaluate", async () => {
        if (!bridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine. Run 'Luna: Debug Connect' first.");
            return;
        }
        const expression = await vscode.window.showInputBox({
            prompt: "Lua expression to evaluate",
            placeHolder: 'e.g. print("hello") or player.x',
        });
        if (!expression) {
            return;
        }
        try {
            const result = await bridge.evaluate(expression);
            bridge.showOutput();
            vscode.window.showInformationMessage(`Result: ${result}`);
        }
        catch (err) {
            vscode.window.showErrorMessage(`Evaluation failed: ${err instanceof Error ? err.message : String(err)}`);
        }
    }));
    // ── luna.debug.hotReload ─────────────────────────────────
    context.subscriptions.push(vscode.commands.registerCommand("luna.debug.hotReload", async () => {
        if (!bridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine.");
            return;
        }
        const editor = vscode.window.activeTextEditor;
        if (!editor || editor.document.languageId !== "lua") {
            vscode.window.showWarningMessage("Open a Lua file to hot-reload.");
            return;
        }
        // Save the file first
        if (editor.document.isDirty) {
            await editor.document.save();
        }
        try {
            const ok = await bridge.hotReload(editor.document.uri);
            if (ok) {
                vscode.window.showInformationMessage(`Hot-reloaded: ${vscode.workspace.asRelativePath(editor.document.uri)}`);
            }
            else {
                vscode.window.showErrorMessage("Hot-reload failed. Check debug output for details.");
            }
        }
        catch (err) {
            vscode.window.showErrorMessage(`Hot-reload error: ${err instanceof Error ? err.message : String(err)}`);
        }
    }));
    // ── luna.debug.showStats ─────────────────────────────────
    context.subscriptions.push(vscode.commands.registerCommand("luna.debug.showStats", async () => {
        if (!bridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine.");
            return;
        }
        bridge.startStatsPolling();
        vscode.window.showInformationMessage("Engine stats enabled in status bar.");
    }));
    // ── luna.debug.inspect ───────────────────────────────────
    context.subscriptions.push(vscode.commands.registerCommand("luna.debug.inspect", async () => {
        if (!bridge.isConnected) {
            vscode.window.showErrorMessage("Not connected to Luna2D engine.");
            return;
        }
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage("No active editor.");
            return;
        }
        // Get word under cursor or selection
        const selection = editor.selection;
        let expression;
        if (!selection.isEmpty) {
            expression = editor.document.getText(selection);
        }
        else {
            const wordRange = editor.document.getWordRangeAtPosition(selection.active, /[\w.:\[\]]+/);
            if (!wordRange) {
                vscode.window.showWarningMessage("No variable found at cursor.");
                return;
            }
            expression = editor.document.getText(wordRange);
        }
        try {
            const result = await bridge.evaluate(`return tostring(${expression})`);
            const typeResult = await bridge.evaluate(`return type(${expression})`);
            vscode.window.showInformationMessage(`${expression} = ${result} (${typeResult})`);
        }
        catch (err) {
            vscode.window.showErrorMessage(`Failed to inspect '${expression}': ${err instanceof Error ? err.message : String(err)}`);
        }
    }));
}
//# sourceMappingURL=debugBridge.js.map