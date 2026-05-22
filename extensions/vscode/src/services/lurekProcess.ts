import * as vscode from "vscode";
import * as path from "path";
import * as fs from "fs";
import { buildRunCommand } from "./parallelCargo.js";

/**
 * Manages the Lurek2D game process lifecycle — finding the binary,
 * launching, stopping, and reporting status.
 */
export class LurekProcessService {
  private readonly terminals = new Set<vscode.Terminal>();
  private readonly terminalCloseListener: vscode.Disposable;
  private runCounter = 0;
  private readonly _onStatusChange = new vscode.EventEmitter<boolean>();
  public readonly onStatusChange = this._onStatusChange.event;

  constructor() {
    this.terminalCloseListener = vscode.window.onDidCloseTerminal((terminal) => {
      if (!this.terminals.delete(terminal)) {
        return;
      }

      if (this.terminals.size === 0) {
        this._onStatusChange.fire(false);
        void vscode.commands.executeCommand("setContext", "lurek.gameRunning", false);
      }
    });
  }

  /**
   * Finds an installed lurek2d binary. Checks the user setting first,
   * then PATH, then falls back to the repo wrapper if the workspace contains Cargo.toml.
   */
  async findLurekBinary(): Promise<string | undefined> {
    // 1. Check user setting
    const configured = getConfiguredBinaryPath();
    if (configured && fs.existsSync(configured)) {
      return configured;
    }

    // 2. Check PATH for lurek2d
    const binaryName = process.platform === "win32" ? "lurek2d.exe" : "lurek2d";
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
        return undefined;
      }
    }

    throw new Error(
      "Lurek2D binary not found. Install it or set lurek.lurekPath in settings."
    );
  }

  /**
   * Runs the game in an integrated terminal.
   */
  async run(gameDir: string, args: string[] = []): Promise<void> {
    const saveOnRun = vscode.workspace
      .getConfiguration("lurek")
      .get<boolean>("saveOnRun", true);
    if (saveOnRun) {
      await vscode.workspace.saveAll(false);
    }

    const binary = await this.findLurekBinary();
    const launchArgs = [gameDir, ...args];
    const workspaceRoot = getWorkspaceRoot();
    const terminalOptions: vscode.TerminalOptions = {
      name: `Lurek2D Debug #${++this.runCounter}`,
    };
    if (workspaceRoot) {
      terminalOptions.cwd = workspaceRoot;
    }
    if (binary) {
      // Launch the installed binary directly so paths like Program Files do not
      // depend on the user's shell quoting rules.
      terminalOptions.shellPath = binary;
      terminalOptions.shellArgs = launchArgs;
    }

    const terminal = vscode.window.createTerminal(terminalOptions);
    this.terminals.add(terminal);
    terminal.show();
    if (!binary) {
      terminal.sendText(buildRunCommand("debug", launchArgs));
    }

    this._onStatusChange.fire(true);
    void vscode.commands.executeCommand("setContext", "lurek.gameRunning", true);
  }

  /**
   * Stops the running game process.
   */
  stop(): void {
    const running = Array.from(this.terminals);
    this.terminals.clear();

    for (const terminal of running) {
      terminal.dispose();
    }

    this._onStatusChange.fire(false);
    void vscode.commands.executeCommand("setContext", "lurek.gameRunning", false);
  }

  /**
   * Returns whether a game process is currently running.
   */
  isRunning(): boolean {
    return this.terminals.size > 0;
  }

  dispose(): void {
    this.stop();
    this.terminalCloseListener.dispose();
    this._onStatusChange.dispose();
  }
}

function getWorkspaceRoot(): string | undefined {
  const folders = vscode.workspace.workspaceFolders;
  return folders?.[0]?.uri.fsPath;
}

function getConfiguredBinaryPath(): string {
  const config = vscode.workspace.getConfiguration("lurek");
  const configuredPaths = [
    config.get<string>("lurekPath", ""),
    config.get<string>("enginePath", ""),
  ];

  for (const configuredPath of configuredPaths) {
    const trimmed = configuredPath.trim();
    if (trimmed.length > 0) {
      return trimmed;
    }
  }

  return "";
}
