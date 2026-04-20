import * as vscode from "vscode";
import * as path from "path";
import * as fs from "fs";
import { buildRunCommand, buildTerminalCommand } from "./parallelCargo.js";

/**
 * Manages the Lurek2D game process lifecycle — finding the binary,
 * launching, stopping, and reporting status.
 */
export class LurekProcessService {
  private terminal: vscode.Terminal | null = null;
  private readonly _onStatusChange = new vscode.EventEmitter<boolean>();
  public readonly onStatusChange = this._onStatusChange.event;

  /**
   * Finds an installed lurek2d binary. Checks the user setting first,
   * then PATH, then falls back to the repo wrapper if the workspace contains Cargo.toml.
   */
  async findLurekBinary(): Promise<string | undefined> {
    // 1. Check user setting
    const configured = vscode.workspace
      .getConfiguration("lurek")
      .get<string>("enginePath", "");
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
    if (this.isRunning()) {
      vscode.window.showWarningMessage("Lurek2D is already running.");
      return;
    }

    const saveOnRun = vscode.workspace
      .getConfiguration("lurek")
      .get<boolean>("saveOnRun", true);
    if (saveOnRun) {
      await vscode.workspace.saveAll(false);
    }

    const binary = await this.findLurekBinary();
    const launchArgs = [gameDir, ...args];
    const cmd = binary
      ? buildTerminalCommand(binary, launchArgs)
      : buildRunCommand("debug", launchArgs);

    this.terminal = vscode.window.createTerminal({
      name: "Lurek2D",
      cwd: getWorkspaceRoot(),
    });
    this.terminal.show();
    this.terminal.sendText(cmd);

    this._onStatusChange.fire(true);
    vscode.commands.executeCommand("setContext", "lurek.gameRunning", true);
  }

  /**
   * Stops the running game process.
   */
  stop(): void {
    if (this.terminal) {
      this.terminal.dispose();
      this.terminal = null;
    }
    this._onStatusChange.fire(false);
    vscode.commands.executeCommand("setContext", "lurek.gameRunning", false);
  }

  /**
   * Returns whether a game process is currently running.
   */
  isRunning(): boolean {
    return this.terminal !== null;
  }

  dispose(): void {
    this.stop();
    this._onStatusChange.dispose();
  }
}

function getWorkspaceRoot(): string | undefined {
  const folders = vscode.workspace.workspaceFolders;
  return folders?.[0]?.uri.fsPath;
}
