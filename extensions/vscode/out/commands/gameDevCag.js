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
exports.registerGameDevCagCommands = registerGameDevCagCommands;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
// ─── Constants ────────────────────────────────────────────
const CAG_COMPONENTS = [
    { label: "Agents", description: "AI agent definitions for game dev roles", srcDir: "agents" },
    { label: "Skills", description: "Domain skill packages for AI assistants", srcDir: "skills" },
    { label: "Prompts", description: "Task-driven playbooks for game development", srcDir: "prompts" },
    { label: "Instructions", description: "Contextual coding instructions", srcDir: "instructions" },
];
const TEMPLATES = [
    { label: "Minimal", description: "Bare-bones starter with essential callbacks", dir: "minimal" },
    { label: "Game Loop", description: "Structured loop with class system and event bus", dir: "game-loop" },
    { label: "Platformer", description: "Side-scrolling platformer with jump physics", dir: "platformer" },
    { label: "Top-Down RPG", description: "8-dir movement, scene management, HUD", dir: "top-down-rpg" },
    { label: "Shoot 'em Up", description: "Vertical scrolling shooter with bullet pool", dir: "shoot-em-up" },
    { label: "Puzzle", description: "Grid-based puzzle with click interaction", dir: "puzzle" },
    { label: "Roguelike", description: "Turn-based with BSP dungeon generation", dir: "roguelike" },
    { label: "Visual Novel", description: "Typewriter dialog and scene progression", dir: "visual-novel" },
    { label: "Arcade", description: "Simple arcade loop with score and lives", dir: "arcade" },
    { label: "Tower Defense", description: "Path-following enemies, placeable towers, waves", dir: "tower-defense" },
    { label: "Game Jam", description: "Minimal fast-start template for game jams", dir: "game-jam" },
    { label: "Demo Scene", description: "Scene switcher with multiple demo scenes", dir: "demo-scene" },
];
// ─── Helpers ──────────────────────────────────────────────
function getGameDevCagRoot(context) {
    return path.join(context.extensionPath, "cag", "game-dev");
}
function getWorkspaceRoot() {
    return vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
}
/** Recursively copy a directory tree. */
function copyDirRecursive(src, dest) {
    if (!fs.existsSync(dest)) {
        fs.mkdirSync(dest, { recursive: true });
    }
    for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
        const srcPath = path.join(src, entry.name);
        const destPath = path.join(dest, entry.name);
        if (entry.isDirectory()) {
            copyDirRecursive(srcPath, destPath);
        }
        else {
            fs.copyFileSync(srcPath, destPath);
        }
    }
}
/** Count files recursively in a directory. */
function countFiles(dir) {
    if (!fs.existsSync(dir)) {
        return 0;
    }
    let count = 0;
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        if (entry.isDirectory()) {
            count += countFiles(path.join(dir, entry.name));
        }
        else {
            count++;
        }
    }
    return count;
}
// ─── Commands ─────────────────────────────────────────────
/**
 * Deploy Game Dev AI Layer — multi-select which CAG components to install.
 */
async function deployCag(context) {
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const cagRoot = getGameDevCagRoot(context);
    if (!fs.existsSync(cagRoot)) {
        vscode.window.showErrorMessage("Game Dev CAG files not found in extension bundle.");
        return;
    }
    const picks = await vscode.window.showQuickPick(CAG_COMPONENTS.map((c) => ({
        label: c.label,
        description: c.description,
        picked: true,
        srcDir: c.srcDir,
    })), {
        canPickMany: true,
        placeHolder: "Select CAG components to deploy",
        title: "Deploy Game Dev AI Layer",
    });
    if (!picks || picks.length === 0) {
        return;
    }
    const targetGithub = path.join(root, ".github");
    let totalFiles = 0;
    for (const pick of picks) {
        const srcDir = path.join(cagRoot, pick.srcDir);
        if (!fs.existsSync(srcDir)) {
            continue;
        }
        const destDir = path.join(targetGithub, pick.srcDir);
        copyDirRecursive(srcDir, destDir);
        totalFiles += countFiles(srcDir);
    }
    vscode.window.showInformationMessage(`Deployed ${totalFiles} file(s) to .github/ (${picks.map((p) => p.label).join(", ")})`);
}
/**
 * Scaffold a project from one of the 12 built-in templates.
 */
async function scaffoldFromTemplate(context) {
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const cagRoot = getGameDevCagRoot(context);
    const templatesRoot = path.join(cagRoot, "templates");
    if (!fs.existsSync(templatesRoot)) {
        vscode.window.showErrorMessage("Game Dev templates not found in extension bundle.");
        return;
    }
    const pick = await vscode.window.showQuickPick(TEMPLATES.map((t) => ({ label: t.label, description: t.description, dir: t.dir })), { placeHolder: "Select a game template", title: "Scaffold Project from Template" });
    if (!pick) {
        return;
    }
    const srcDir = path.join(templatesRoot, pick.dir);
    if (!fs.existsSync(srcDir)) {
        vscode.window.showErrorMessage(`Template "${pick.label}" not found.`);
        return;
    }
    // Check for existing main.lua
    const mainLua = path.join(root, "main.lua");
    if (fs.existsSync(mainLua)) {
        const overwrite = await vscode.window.showWarningMessage("main.lua already exists in workspace. Overwrite project files?", "Yes", "No");
        if (overwrite !== "Yes") {
            return;
        }
    }
    copyDirRecursive(srcDir, root);
    const fileCount = countFiles(srcDir);
    vscode.window.showInformationMessage(`Scaffolded "${pick.label}" template (${fileCount} files)`);
    // Open main.lua
    const newMain = path.join(root, "main.lua");
    if (fs.existsSync(newMain)) {
        const doc = await vscode.workspace.openTextDocument(newMain);
        await vscode.window.showTextDocument(doc);
    }
}
/**
 * Update Game Dev AI Layer — overwrite existing .github/ CAG files with latest.
 */
async function updateCag(context) {
    const root = getWorkspaceRoot();
    if (!root) {
        vscode.window.showErrorMessage("No workspace folder open.");
        return;
    }
    const targetGithub = path.join(root, ".github");
    if (!fs.existsSync(targetGithub)) {
        vscode.window.showInformationMessage("No .github/ folder found. Use 'Deploy Game Dev AI Layer' first.");
        return;
    }
    const confirm = await vscode.window.showWarningMessage("This will overwrite existing CAG files in .github/ with the latest from the extension. Continue?", "Yes", "No");
    if (confirm !== "Yes") {
        return;
    }
    const cagRoot = getGameDevCagRoot(context);
    let totalFiles = 0;
    for (const comp of CAG_COMPONENTS) {
        const srcDir = path.join(cagRoot, comp.srcDir);
        if (!fs.existsSync(srcDir)) {
            continue;
        }
        const destDir = path.join(targetGithub, comp.srcDir);
        copyDirRecursive(srcDir, destDir);
        totalFiles += countFiles(srcDir);
    }
    vscode.window.showInformationMessage(`Updated ${totalFiles} CAG file(s) in .github/`);
}
// ─── Registration ─────────────────────────────────────────
function registerGameDevCagCommands(context) {
    context.subscriptions.push(vscode.commands.registerCommand("luna.cag.deploy", () => deployCag(context)), vscode.commands.registerCommand("luna.cag.scaffold", () => scaffoldFromTemplate(context)), vscode.commands.registerCommand("luna.cag.updateGameDev", () => updateCag(context)));
}
//# sourceMappingURL=gameDevCag.js.map