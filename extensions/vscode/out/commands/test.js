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
exports.testAll = testAll;
exports.testModule = testModule;
exports.testLuaAll = testLuaAll;
exports.testLuaGolden = testLuaGolden;
exports.generateTestForFile = generateTestForFile;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
/**
 * Runs all tests (cargo test).
 */
function testAll() {
    const terminal = getOrCreateTerminal("Luna Tests");
    terminal.show();
    terminal.sendText("cargo test");
}
/**
 * Runs a specific Rust test module.
 */
function testModule(moduleName) {
    const terminal = getOrCreateTerminal("Luna Tests");
    terminal.show();
    terminal.sendText(`cargo test ${moduleName}_tests`);
}
/**
 * Runs all Lua integration tests.
 */
function testLuaAll() {
    const terminal = getOrCreateTerminal("Luna Tests");
    terminal.show();
    terminal.sendText("cargo test --test lua_tests");
}
/**
 * Runs golden (snapshot) tests.
 */
function testLuaGolden() {
    const terminal = getOrCreateTerminal("Luna Tests");
    terminal.show();
    terminal.sendText("cargo test --test golden_tests");
}
/**
 * Generates test boilerplate for the currently open file.
 */
async function generateTestForFile() {
    const editor = vscode.window.activeTextEditor;
    if (!editor) {
        vscode.window.showWarningMessage("No active editor.");
        return;
    }
    const filePath = editor.document.fileName;
    const fileName = path.basename(filePath, path.extname(filePath));
    const ext = path.extname(filePath);
    const wsRoot = vscode.workspace.workspaceFolders?.[0]?.uri.fsPath;
    // ── Lua file → generate a tests/lua/<name>_test.lua ──────────────────────
    if (ext === ".lua") {
        const testDir = wsRoot ? path.join(wsRoot, "tests", "lua") : null;
        const testFile = testDir ? path.join(testDir, `${fileName}_test.lua`) : null;
        if (testFile && fs.existsSync(testFile)) {
            const doc = await vscode.workspace.openTextDocument(testFile);
            await vscode.window.showTextDocument(doc);
            vscode.window.showInformationMessage(`Opened existing test: tests/lua/${fileName}_test.lua`);
            return;
        }
        const skeleton = `-- Tests for ${fileName}.lua
-- Run with: cargo run -- tests/lua/${fileName}_test.lua

local passed, failed = 0, 0

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print("[PASS] " .. name)
  else
    failed = failed + 1
    print("[FAIL] " .. name .. ": " .. tostring(err))
  end
end

-- ──────────────────────────────────────────────────
-- Add tests below

test("example: math works", function()
  assert(1 + 1 == 2, "basic arithmetic failed")
end)

-- ──────────────────────────────────────────────────
print(string.format("\\n%d passed, %d failed", passed, failed))
if failed > 0 then error(failed .. " test(s) failed") end
`;
        if (testDir && !fs.existsSync(testDir)) {
            fs.mkdirSync(testDir, { recursive: true });
        }
        if (testFile) {
            fs.writeFileSync(testFile, skeleton, "utf-8");
            const doc = await vscode.workspace.openTextDocument(testFile);
            await vscode.window.showTextDocument(doc);
            vscode.window.showInformationMessage(`✅ Created: tests/lua/${fileName}_test.lua`);
        }
        return;
    }
    // ── Rust file → generate or open tests/<module>_tests.rs ─────────────────
    if (ext === ".rs") {
        // Derive module name from file path (e.g. src/physics/mod.rs → physics)
        const parts = filePath.replace(/\\/g, "/").split("/src/");
        const relPart = parts.length > 1 ? parts[parts.length - 1] : fileName;
        const moduleName = relPart.split("/")[0] === fileName ? fileName : relPart.split("/")[0];
        const testFile = wsRoot ? path.join(wsRoot, "tests", `${moduleName}_tests.rs`) : null;
        if (testFile && fs.existsSync(testFile)) {
            const doc = await vscode.workspace.openTextDocument(testFile);
            await vscode.window.showTextDocument(doc);
            vscode.window.showInformationMessage(`Opened existing test: tests/${moduleName}_tests.rs`);
            return;
        }
        const skeleton = `//! Integration tests for the \`${moduleName}\` module.

use luna2d::${moduleName};

fn make_test_state() {
    // TODO: set up any required state here
}

#[test]
fn test_${moduleName}_basic() {
    // TODO: replace with a real test
    assert!(true);
}

#[test]
fn test_${moduleName}_example() {
    // TODO: add meaningful assertions
    let result = true;
    assert!(result, "expected true");
}
`;
        if (testFile) {
            fs.writeFileSync(testFile, skeleton, "utf-8");
            const doc = await vscode.workspace.openTextDocument(testFile);
            await vscode.window.showTextDocument(doc);
            vscode.window.showInformationMessage(`✅ Created: tests/${moduleName}_tests.rs`);
        }
        return;
    }
    vscode.window.showWarningMessage(`Test generation is not supported for ${ext} files.`);
}
function getOrCreateTerminal(name) {
    const existing = vscode.window.terminals.find((t) => t.name === name);
    if (existing) {
        return existing;
    }
    return vscode.window.createTerminal(name);
}
//# sourceMappingURL=test.js.map