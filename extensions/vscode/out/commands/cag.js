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
exports.installCag = installCag;
exports.selectAgent = selectAgent;
exports.selectSkill = selectSkill;
exports.selectPrompt = selectPrompt;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
/**
 * Installs the CAG (AI config) files from the engine's .github/ directory
 * into the current workspace.
 */
async function installCag() {
    const root = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    // The engine's own .github/ dir (this extension ships inside the engine repo)
    // Walk up from __dirname to find the repo root's .github/
    let engineGithub = null;
    let dir = __dirname;
    for (let i = 0; i < 6; i++) {
        const candidate = path.join(dir, ".github");
        if (fs.existsSync(candidate)) {
            engineGithub = candidate;
            break;
        }
        dir = path.dirname(dir);
    }
    if (!engineGithub) {
        vscode.window.showErrorMessage("Could not locate engine .github/ folder. Make sure the extension is run from the luna_2d repository root.");
        return;
    }
    const targetDir = path.join(root, ".github");
    if (fs.existsSync(targetDir)) {
        const overwrite = await vscode.window.showWarningMessage(".github/ directory already exists in your workspace. Overwrite all CAG files?", "Yes — Overwrite", "Cancel");
        if (overwrite !== "Yes — Overwrite") {
            return;
        }
    }
    // Copy recursively
    let copied = 0;
    function copyDir(src, dest) {
        fs.mkdirSync(dest, { recursive: true });
        for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
            const s = path.join(src, entry.name), d = path.join(dest, entry.name);
            if (entry.isDirectory()) {
                copyDir(s, d);
            }
            else {
                fs.copyFileSync(s, d);
                copied++;
            }
        }
    }
    try {
        copyDir(engineGithub, targetDir);
        vscode.window.showInformationMessage(`✅ CAG installed: ${copied} file(s) copied to .github/`);
    }
    catch (err) {
        vscode.window.showErrorMessage(`CAG install failed: ${err}`);
    }
}
/**
 * Shows a quick-pick of available agents.
 */
async function selectAgent() {
    const agents = await listCagFiles("agents", "*.agent.md");
    if (agents.length === 0) {
        vscode.window.showWarningMessage("No agent definitions found.");
        return;
    }
    const picked = await vscode.window.showQuickPick(agents, {
        placeHolder: "Select an agent",
    });
    if (picked) {
        const root = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
        if (root) {
            const filePath = path.join(root, ".github", "agents", picked);
            if (fs.existsSync(filePath)) {
                const doc = await vscode.workspace.openTextDocument(filePath);
                await vscode.window.showTextDocument(doc);
            }
        }
    }
}
/**
 * Shows a quick-pick of available skills.
 */
async function selectSkill() {
    const root = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const skillsDir = path.join(root, ".github", "skills");
    if (!fs.existsSync(skillsDir)) {
        vscode.window.showWarningMessage("No skills directory found.");
        return;
    }
    const skills = fs
        .readdirSync(skillsDir, { withFileTypes: true })
        .filter((e) => e.isDirectory())
        .map((e) => e.name);
    if (skills.length === 0) {
        vscode.window.showWarningMessage("No skills found.");
        return;
    }
    const picked = await vscode.window.showQuickPick(skills, {
        placeHolder: "Select a skill",
    });
    if (picked) {
        const skillFile = path.join(skillsDir, picked, "SKILL.md");
        if (fs.existsSync(skillFile)) {
            const doc = await vscode.workspace.openTextDocument(skillFile);
            await vscode.window.showTextDocument(doc);
        }
    }
}
/**
 * Shows a quick-pick of available prompts.
 */
async function selectPrompt() {
    const prompts = await listCagFiles("prompts", "*.prompt.md");
    if (prompts.length === 0) {
        vscode.window.showWarningMessage("No prompts found.");
        return;
    }
    const picked = await vscode.window.showQuickPick(prompts, {
        placeHolder: "Select a prompt",
    });
    if (picked) {
        const root = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
        if (root) {
            const filePath = path.join(root, ".github", "prompts", picked);
            if (fs.existsSync(filePath)) {
                const doc = await vscode.workspace.openTextDocument(filePath);
                await vscode.window.showTextDocument(doc);
            }
        }
    }
}
async function listCagFiles(subdir, _pattern) {
    const root = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    if (!root) {
        return [];
    }
    const dir = path.join(root, ".github", subdir);
    if (!fs.existsSync(dir)) {
        return [];
    }
    try {
        return fs
            .readdirSync(dir, { withFileTypes: true })
            .filter((e) => e.isFile() && e.name.endsWith(".md"))
            .map((e) => e.name);
    }
    catch {
        return [];
    }
}
//# sourceMappingURL=cag.js.map