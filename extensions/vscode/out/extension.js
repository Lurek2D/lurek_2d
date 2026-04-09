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
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
const server_1 = require("./mcp/server");
const apiCoverageEditor_1 = require("./editors/apiCoverageEditor");
/** Status bar item displayed when the extension is active. */
let statusBarItem;
/** MCP server child process reference. */
let mcpProcess;
/**
 * Activates the Luna2D extension.
 *
 * Called by VS Code when a workspace containing `main.lua` or `Cargo.toml`
 * is opened. Registers commands, starts the MCP server, and shows a status
 * bar indicator.
 */
function activate(context) {
    // Status bar
    statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
    statusBarItem.text = "$(rocket) Luna2D";
    statusBarItem.tooltip = "Luna2D game engine is active";
    statusBarItem.show();
    context.subscriptions.push(statusBarItem);
    // Register commands
    context.subscriptions.push(vscode.commands.registerCommand("luna2d.runExample", runExampleCommand), vscode.commands.registerCommand("luna2d.listExamples", listExamplesCommand), vscode.commands.registerCommand("luna2d.checkBuild", checkBuildCommand), vscode.commands.registerCommand("luna2d.getApiDoc", getApiDocCommand), vscode.commands.registerCommand("luna.editor.apiCoverage", () => apiCoverageEditor_1.ApiCoverageEditor.open(context)));
    // Start MCP server
    const workspaceRoot = getWorkspaceRoot();
    if (workspaceRoot) {
        mcpProcess = (0, server_1.startMcpServer)(workspaceRoot);
    }
    vscode.window.showInformationMessage("Luna2D extension activated.");
}
/**
 * Deactivates the Luna2D extension.
 *
 * Cleans up the MCP server process and status bar item.
 */
function deactivate() {
    if (mcpProcess) {
        mcpProcess.kill();
        mcpProcess = undefined;
    }
}
/**
 * Returns the first workspace folder root path, or undefined if none.
 */
function getWorkspaceRoot() {
    const folders = vscode.workspace.workspaceFolders;
    if (folders && folders.length > 0) {
        return folders[0].uri.fsPath;
    }
    return undefined;
}
/**
 * Returns the path to the examples directory within the workspace.
 */
function getExamplesDir() {
    const root = getWorkspaceRoot();
    if (!root) {
        return undefined;
    }
    const examplesDir = path.join(root, "demos");
    if (fs.existsSync(examplesDir)) {
        return examplesDir;
    }
    return undefined;
}
/**
 * Lists demo directory names from the workspace content/demos/ folder.
 */
function listExampleNames() {
    const examplesDir = getExamplesDir();
    if (!examplesDir) {
        return [];
    }
    try {
        return fs
            .readdirSync(examplesDir, { withFileTypes: true })
            .filter((entry) => entry.isDirectory())
            .map((entry) => entry.name);
    }
    catch {
        return [];
    }
}
/**
 * Command: Luna2D: Run Example
 *
 * Shows a quick-pick list of available examples and runs the selected one
 * in an integrated terminal via `cargo run -- content/demos/<name>`.
 */
async function runExampleCommand() {
    const examples = listExampleNames();
    if (examples.length === 0) {
        vscode.window.showWarningMessage("No Luna2D examples found in workspace.");
        return;
    }
    const selected = await vscode.window.showQuickPick(examples, {
        placeHolder: "Select a Luna2D example to run",
    });
    if (!selected) {
        return;
    }
    const terminal = vscode.window.createTerminal("Luna2D Example");
    terminal.show();
    terminal.sendText(`cargo run -- content/content/demos/${selected}`);
}
/**
 * Command: Luna2D: List Examples
 *
 * Displays the available example names in an information message.
 */
async function listExamplesCommand() {
    const examples = listExampleNames();
    if (examples.length === 0) {
        vscode.window.showWarningMessage("No Luna2D examples found in workspace.");
        return;
    }
    const message = `Luna2D Examples: ${examples.join(", ")}`;
    vscode.window.showInformationMessage(message);
}
/**
 * Command: Luna2D: Check Build
 *
 * Runs `cargo check` in a terminal and reports results.
 */
async function checkBuildCommand() {
    const terminal = vscode.window.createTerminal("Luna2D Build Check");
    terminal.show();
    terminal.sendText("cargo check 2>&1");
}
/**
 * Command: Luna2D: Get API Documentation
 *
 * Prompts the user for a query string and searches the bundled API reference
 * for matching entries. Results are displayed in a new editor tab.
 */
async function getApiDocCommand() {
    const query = await vscode.window.showInputBox({
        placeHolder: "e.g. luna.graphics.draw",
        prompt: "Search Luna2D API documentation",
    });
    if (!query) {
        return;
    }
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const apiDocPath = path.join(root, "docs", "lua_api_reference_generated.md");
    if (!fs.existsSync(apiDocPath)) {
        vscode.window.showWarningMessage("API reference file not found. Run 'python tools/gen_lua_api.py' to generate it.");
        return;
    }
    try {
        const content = fs.readFileSync(apiDocPath, "utf-8");
        const lines = content.split("\n");
        const queryLower = query.toLowerCase();
        // Find sections matching the query
        const matches = [];
        let currentSection = [];
        let inMatch = false;
        for (const line of lines) {
            if (line.startsWith("##")) {
                // Flush previous match
                if (inMatch && currentSection.length > 0) {
                    matches.push(currentSection.join("\n"));
                }
                currentSection = [line];
                inMatch = line.toLowerCase().includes(queryLower);
            }
            else {
                currentSection.push(line);
                if (line.toLowerCase().includes(queryLower)) {
                    inMatch = true;
                }
            }
        }
        // Flush last section
        if (inMatch && currentSection.length > 0) {
            matches.push(currentSection.join("\n"));
        }
        if (matches.length === 0) {
            vscode.window.showInformationMessage(`No API documentation found for "${query}".`);
            return;
        }
        // Show results in a new untitled document
        const resultText = `# Luna2D API — Search: "${query}"\n\n${matches.join("\n\n---\n\n")}`;
        const doc = await vscode.workspace.openTextDocument({
            content: resultText,
            language: "markdown",
        });
        await vscode.window.showTextDocument(doc, { preview: true });
    }
    catch (err) {
        vscode.window.showErrorMessage(`Failed to read API documentation: ${err}`);
    }
}
//# sourceMappingURL=extension.js.map