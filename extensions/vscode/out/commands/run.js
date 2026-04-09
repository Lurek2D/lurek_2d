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
exports.runGame = runGame;
exports.stopGame = stopGame;
exports.runWithArgs = runWithArgs;
exports.runExample = runExample;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
/**
 * Runs the game from the workspace root or a chosen directory.
 */
async function runGame(lunaProcess) {
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    // Determine game directory
    const srcDir = vscode.workspace
        .getConfiguration("luna")
        .get("srcDir", "");
    const gameDir = srcDir ? path.join(root, srcDir) : root;
    try {
        await lunaProcess.run(gameDir);
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        vscode.window.showErrorMessage(`Failed to run Luna2D: ${msg}`);
    }
}
/**
 * Stops the currently running game.
 */
function stopGame(lunaProcess) {
    if (!lunaProcess.isRunning()) {
        vscode.window.showInformationMessage("No Luna2D game is running.");
        return;
    }
    lunaProcess.stop();
    vscode.window.showInformationMessage("Luna2D game stopped.");
}
/**
 * Runs the game with user-provided extra arguments.
 */
async function runWithArgs(lunaProcess) {
    const args = await vscode.window.showInputBox({
        prompt: "Enter arguments for Luna2D",
        placeHolder: "e.g. --debug --fps-cap 60",
    });
    if (args === undefined) {
        return;
    }
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const srcDir = vscode.workspace
        .getConfiguration("luna")
        .get("srcDir", "");
    const gameDir = srcDir ? path.join(root, srcDir) : root;
    try {
        await lunaProcess.run(gameDir, args.split(/\s+/).filter(Boolean));
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        vscode.window.showErrorMessage(`Failed to run Luna2D: ${msg}`);
    }
}
/**
 * Shows a quick-pick list of example projects and runs the selected one.
 */
async function runExample(lunaProcess) {
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const examplesDir = path.join(root, "content", "demos");
    if (!fs.existsSync(examplesDir)) {
        vscode.window.showWarningMessage("No content/content/demos/ directory found.");
        return;
    }
    const examples = fs
        .readdirSync(examplesDir, { withFileTypes: true })
        .filter((e) => e.isDirectory())
        .map((e) => e.name);
    if (examples.length === 0) {
        vscode.window.showWarningMessage("No examples found.");
        return;
    }
    const selected = await vscode.window.showQuickPick(examples, {
        placeHolder: "Select a demo to run",
    });
    if (!selected) {
        return;
    }
    try {
        await lunaProcess.run(path.join(examplesDir, selected));
    }
    catch (err) {
        const msg = err instanceof Error ? err.message : String(err);
        vscode.window.showErrorMessage(`Failed to run example: ${msg}`);
    }
}
function getWorkspaceRoot() {
    return vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
}
//# sourceMappingURL=run.js.map