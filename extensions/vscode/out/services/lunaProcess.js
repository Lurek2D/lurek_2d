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
exports.LunaProcessService = void 0;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
/**
 * Manages the Luna2D game process lifecycle — finding the binary,
 * launching, stopping, and reporting status.
 */
class LunaProcessService {
    process = null;
    terminal = null;
    _onStatusChange = new vscode.EventEmitter();
    onStatusChange = this._onStatusChange.event;
    /**
     * Finds the luna2d binary. Checks the user setting first,
     * then PATH, then falls back to `cargo run`.
     */
    async findLunaBinary() {
        // 1. Check user setting
        const configured = vscode.workspace
            .getConfiguration("luna")
            .get("lunaPath", "");
        if (configured && fs.existsSync(configured)) {
            return configured;
        }
        // 2. Check PATH for luna / luna.exe
        const binaryName = process.platform === "win32" ? "luna.exe" : "luna";
        const pathDirs = (process.env.PATH ?? "").split(path.delimiter);
        for (const dir of pathDirs) {
            const candidate = path.join(dir, binaryName);
            if (fs.existsSync(candidate)) {
                return candidate;
            }
        }
        // 3. Check workspace for cargo
        const workspaceRoot = getWorkspaceRoot();
        if (workspaceRoot) {
            const cargoToml = path.join(workspaceRoot, "Cargo.toml");
            if (fs.existsSync(cargoToml)) {
                return "cargo run --";
            }
        }
        throw new Error("Luna2D binary not found. Install it or set luna.lunaPath in settings.");
    }
    /**
     * Runs the game in an integrated terminal.
     */
    async run(gameDir, args = []) {
        if (this.isRunning()) {
            vscode.window.showWarningMessage("Luna2D is already running.");
            return;
        }
        const saveOnRun = vscode.workspace
            .getConfiguration("luna")
            .get("saveOnRun", true);
        if (saveOnRun) {
            await vscode.workspace.saveAll(false);
        }
        const binary = await this.findLunaBinary();
        const cmd = binary.startsWith("cargo run")
            ? `${binary} ${gameDir} ${args.join(" ")}`.trim()
            : `"${binary}" ${gameDir} ${args.join(" ")}`.trim();
        this.terminal = vscode.window.createTerminal({
            name: "Luna2D",
            cwd: getWorkspaceRoot(),
        });
        this.terminal.show();
        this.terminal.sendText(cmd);
        this._onStatusChange.fire(true);
        vscode.commands.executeCommand("setContext", "luna.gameRunning", true);
    }
    /**
     * Stops the running game process.
     */
    stop() {
        if (this.terminal) {
            this.terminal.dispose();
            this.terminal = null;
        }
        if (this.process) {
            this.process.kill();
            this.process = null;
        }
        this._onStatusChange.fire(false);
        vscode.commands.executeCommand("setContext", "luna.gameRunning", false);
    }
    /**
     * Returns whether a game process is currently running.
     */
    isRunning() {
        return this.terminal !== null;
    }
    dispose() {
        this.stop();
        this._onStatusChange.dispose();
    }
}
exports.LunaProcessService = LunaProcessService;
function getWorkspaceRoot() {
    const folders = vscode.workspace.workspaceFolders;
    return folders?.[0]?.uri.fsPath;
}
//# sourceMappingURL=lunaProcess.js.map