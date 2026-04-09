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
exports.StatusBarService = void 0;
const vscode = __importStar(require("vscode"));
/**
 * Manages the Luna Toolkit status bar indicator.
 */
class StatusBarService {
    item;
    constructor() {
        this.item = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
        this.setStopped();
        this.item.show();
    }
    /** Show "Running" state with play icon. */
    setRunning() {
        this.item.text = "$(play) Luna2D: Running";
        this.item.tooltip = "Luna2D game is running — click to stop";
        this.item.command = "luna.stopGame";
        this.item.backgroundColor = new vscode.ThemeColor("statusBarItem.warningBackground");
    }
    /** Show default idle state. */
    setStopped() {
        this.item.text = "$(rocket) Luna2D";
        this.item.tooltip = "Luna Toolkit — click to run game";
        this.item.command = "luna.runGame";
        this.item.backgroundColor = undefined;
    }
    /** Show debug-connected state. */
    setDebugConnected() {
        this.item.text = "$(debug-alt) Luna2D: Debug";
        this.item.tooltip = "Luna2D debug bridge connected";
        this.item.command = "luna.debug.status";
        this.item.backgroundColor = new vscode.ThemeColor("statusBarItem.prominentBackground");
    }
    dispose() {
        this.item.dispose();
    }
}
exports.StatusBarService = StatusBarService;
//# sourceMappingURL=statusBar.js.map