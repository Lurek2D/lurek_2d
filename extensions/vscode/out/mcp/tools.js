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
exports.getToolDefinitions = getToolDefinitions;
exports.handleRunExample = handleRunExample;
exports.handleGetApiDoc = handleGetApiDoc;
exports.handleListExamples = handleListExamples;
exports.handleRunLuaTest = handleRunLuaTest;
exports.handleCheckBuild = handleCheckBuild;
exports.handleGetLogs = handleGetLogs;
const child_process = __importStar(require("child_process"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
/**
 * Returns all MCP tool definitions for the Luna2D server.
 */
function getToolDefinitions() {
    return [
        {
            name: "luna2d.runExample",
            description: "Build and run a named Luna2D example, returning its output.",
            inputSchema: {
                type: "object",
                properties: {
                    name: {
                        type: "string",
                        description: 'Name of the example directory (e.g. "hello_world").',
                    },
                },
                required: ["name"],
            },
        },
        {
            name: "luna2d.getApiDoc",
            description: "Search the Luna2D Lua API documentation for a query string.",
            inputSchema: {
                type: "object",
                properties: {
                    query: {
                        type: "string",
                        description: 'Search query (e.g. "luna.graphics.draw" or "physics").',
                    },
                },
                required: ["query"],
            },
        },
        {
            name: "luna2d.listExamples",
            description: "List all available Luna2D example directories.",
            inputSchema: {
                type: "object",
                properties: {},
            },
        },
        {
            name: "luna2d.runLuaTest",
            description: "Run a Lua test file against a debug build of Luna2D.",
            inputSchema: {
                type: "object",
                properties: {
                    file: {
                        type: "string",
                        description: "Path to the Lua test file, relative to workspace root.",
                    },
                },
                required: ["file"],
            },
        },
        {
            name: "luna2d.checkBuild",
            description: "Run `cargo check` and return compiler diagnostics.",
            inputSchema: {
                type: "object",
                properties: {},
            },
        },
        {
            name: "luna2d.getLogs",
            description: "Return the last N lines of Luna2D engine log output.",
            inputSchema: {
                type: "object",
                properties: {
                    lines: {
                        type: "number",
                        description: "Number of log lines to return (default: 50).",
                    },
                },
            },
        },
    ];
}
/**
 * Executes a shell command in the workspace and returns combined output.
 *
 * @param command - The command string to execute.
 * @param cwd - Working directory for the command.
 * @param timeoutMs - Maximum execution time in milliseconds.
 * @returns Combined stdout and stderr output.
 */
function execCommand(command, cwd, timeoutMs = 60_000) {
    return new Promise((resolve) => {
        child_process.exec(command, { cwd, timeout: timeoutMs, maxBuffer: 1024 * 1024 }, (error, stdout, stderr) => {
            const output = (stdout || "") + (stderr || "");
            if (error) {
                resolve(`${output}\n[exit code: ${error.code ?? "unknown"}]`);
            }
            else {
                resolve(output || "(no output)");
            }
        });
    });
}
/**
 * Creates the handler for `luna2d.runExample`.
 *
 * Builds and runs the specified demo via `cargo run -- content/demos/<name>`.
 */
function handleRunExample(workspaceRoot) {
    return async (args) => {
        const name = args.name;
        if (!name) {
            return "Error: 'name' parameter is required.";
        }
        // Validate example exists
        const exampleDir = path.join(workspaceRoot, "demos", name);
        if (!fs.existsSync(exampleDir)) {
            const available = listExampleDirs(workspaceRoot);
            return `Demo "${name}" not found. Available: ${available.join(", ")}`;
        }
        return execCommand(`cargo run -- content/content/demos/${name}`, workspaceRoot, 120_000);
    };
}
/**
 * Creates the handler for `luna2d.getApiDoc`.
 *
 * Searches the generated API reference markdown for sections matching
 * the query string (case-insensitive).
 */
function handleGetApiDoc(workspaceRoot) {
    return async (args) => {
        const query = args.query;
        if (!query) {
            return "Error: 'query' parameter is required.";
        }
        const apiDocPath = path.join(workspaceRoot, "docs", "API", "lua_api_reference_generated.md");
        if (!fs.existsSync(apiDocPath)) {
            return "API reference not found. Run 'python tools/gen_lua_api.py' to generate it.";
        }
        const content = fs.readFileSync(apiDocPath, "utf-8");
        const lines = content.split("\n");
        const queryLower = query.toLowerCase();
        const matches = [];
        let currentSection = [];
        let inMatch = false;
        for (const line of lines) {
            if (line.startsWith("##")) {
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
        if (inMatch && currentSection.length > 0) {
            matches.push(currentSection.join("\n"));
        }
        if (matches.length === 0) {
            return `No documentation found for "${query}".`;
        }
        return matches.join("\n\n---\n\n");
    };
}
/**
 * Creates the handler for `luna2d.listExamples`.
 *
 * Returns a newline-separated list of example directory names.
 */
function handleListExamples(workspaceRoot) {
    return async () => {
        const examples = listExampleDirs(workspaceRoot);
        if (examples.length === 0) {
            return "No demos found in content/content/demos/ directory.";
        }
        return examples.join("\n");
    };
}
/**
 * Creates the handler for `luna2d.runLuaTest`.
 *
 * Runs a Lua test file via `cargo run -- <file>`.
 */
function handleRunLuaTest(workspaceRoot) {
    return async (args) => {
        const file = args.file;
        if (!file) {
            return "Error: 'file' parameter is required.";
        }
        // Prevent path traversal
        const resolved = path.resolve(workspaceRoot, file);
        if (!resolved.startsWith(workspaceRoot)) {
            return "Error: file path must be within the workspace.";
        }
        if (!fs.existsSync(resolved)) {
            return `Test file not found: ${file}`;
        }
        return execCommand(`cargo run -- ${file}`, workspaceRoot, 120_000);
    };
}
/**
 * Creates the handler for `luna2d.checkBuild`.
 *
 * Runs `cargo check` and returns the compiler output.
 */
function handleCheckBuild(workspaceRoot) {
    return async () => {
        return execCommand("cargo check 2>&1", workspaceRoot, 120_000);
    };
}
/**
 * Creates the handler for `luna2d.getLogs`.
 *
 * Returns the last N lines from the engine log file, if any.
 * Falls back to a message indicating no log file was found.
 */
function handleGetLogs(workspaceRoot) {
    return async (args) => {
        const lines = args.lines || 50;
        // Check common log file locations
        const logPaths = [
            path.join(workspaceRoot, "luna2d.log"),
            path.join(workspaceRoot, "target", "luna2d.log"),
        ];
        for (const logPath of logPaths) {
            if (fs.existsSync(logPath)) {
                const content = fs.readFileSync(logPath, "utf-8");
                const allLines = content.split("\n");
                const tail = allLines.slice(-lines);
                return tail.join("\n");
            }
        }
        return "No log file found. Engine logs are written to stdout by default. Use RUST_LOG=luna2d=debug to enable verbose logging.";
    };
}
/**
 * Lists demo directory names from the workspace content/demos/ folder.
 */
function listExampleDirs(workspaceRoot) {
    const examplesDir = path.join(workspaceRoot, "demos");
    if (!fs.existsSync(examplesDir)) {
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
//# sourceMappingURL=tools.js.map