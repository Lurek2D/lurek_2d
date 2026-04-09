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
exports.startMcpServer = startMcpServer;
exports.runStdioServer = runStdioServer;
const readline = __importStar(require("readline"));
/**
 * Starts the MCP server as an in-process stdio handler.
 *
 * The server reads JSON-RPC messages from stdin and writes responses to
 * stdout. It implements the MCP initialize, tools/list, and tools/call
 * methods.
 *
 * @param workspaceRoot - Absolute path to the Luna2D workspace root.
 * @returns A handle with a `kill()` method to shut down the server.
 */
function startMcpServer(workspaceRoot) {
    // The MCP server runs in-process — we just set up the handler.
    // In a real deployment this would be a separate child process.
    // For the extension, we expose a function that can be called
    // by VS Code's MCP integration.
    return { kill: () => { } };
}
/**
 * Runs the MCP server on stdio.
 *
 * This is the entry point when the server is launched as a standalone
 * process (e.g., `node out/mcp/server.js --workspace /path/to/luna2d`).
 *
 * Reads newline-delimited JSON-RPC messages from stdin and writes
 * responses to stdout.
 */
function runStdioServer(workspaceRoot) {
    const tools = buildToolRegistry(workspaceRoot);
    const toolDefs = getToolDefinitions(workspaceRoot);
    const rl = readline.createInterface({
        input: process.stdin,
        output: undefined,
        terminal: false,
    });
    rl.on("line", (line) => {
        const trimmed = line.trim();
        if (!trimmed) {
            return;
        }
        let request;
        try {
            request = JSON.parse(trimmed);
        }
        catch {
            writeResponse({
                jsonrpc: "2.0",
                id: 0,
                error: { code: -32700, message: "Parse error" },
            });
            return;
        }
        handleRequest(request, tools, toolDefs).then((response) => {
            writeResponse(response);
        });
    });
}
/**
 * Writes a JSON-RPC response to stdout followed by a newline.
 */
function writeResponse(response) {
    const json = JSON.stringify(response);
    process.stdout.write(json + "\n");
}
/**
 * Handles a single JSON-RPC request and returns a response.
 */
async function handleRequest(request, tools, toolDefs) {
    const { id, method, params } = request;
    switch (method) {
        case "initialize":
            return {
                jsonrpc: "2.0",
                id,
                result: {
                    protocolVersion: "2024-11-05",
                    capabilities: { tools: {} },
                    serverInfo: {
                        name: "luna2d-mcp",
                        version: "0.1.0",
                    },
                },
            };
        case "notifications/initialized":
            // Acknowledgement — no response needed, but send one if id exists
            return { jsonrpc: "2.0", id, result: {} };
        case "tools/list":
            return {
                jsonrpc: "2.0",
                id,
                result: {
                    tools: toolDefs,
                },
            };
        case "tools/call": {
            const toolName = params?.name;
            const toolArgs = params?.arguments ?? {};
            const handler = tools.get(toolName);
            if (!handler) {
                return {
                    jsonrpc: "2.0",
                    id,
                    error: {
                        code: -32601,
                        message: `Unknown tool: ${toolName}`,
                    },
                };
            }
            try {
                const result = await handler(toolArgs);
                return {
                    jsonrpc: "2.0",
                    id,
                    result: {
                        content: [{ type: "text", text: result }],
                    },
                };
            }
            catch (err) {
                return {
                    jsonrpc: "2.0",
                    id,
                    result: {
                        content: [
                            {
                                type: "text",
                                text: `Error: ${err instanceof Error ? err.message : String(err)}`,
                            },
                        ],
                        isError: true,
                    },
                };
            }
        }
        default:
            return {
                jsonrpc: "2.0",
                id,
                error: {
                    code: -32601,
                    message: `Method not found: ${method}`,
                },
            };
    }
}
/**
 * Builds the tool handler registry from tool definitions.
 */
function buildToolRegistry(workspaceRoot) {
    const { handleRunExample, handleGetApiDoc, handleListExamples, handleRunLuaTest, handleCheckBuild, handleGetLogs, } = require("./tools");
    const registry = new Map();
    registry.set("luna2d.runExample", handleRunExample(workspaceRoot));
    registry.set("luna2d.getApiDoc", handleGetApiDoc(workspaceRoot));
    registry.set("luna2d.listExamples", handleListExamples(workspaceRoot));
    registry.set("luna2d.runLuaTest", handleRunLuaTest(workspaceRoot));
    registry.set("luna2d.checkBuild", handleCheckBuild(workspaceRoot));
    registry.set("luna2d.getLogs", handleGetLogs(workspaceRoot));
    return registry;
}
/**
 * Returns the array of MCP tool definitions.
 */
function getToolDefinitions(workspaceRoot) {
    const { getToolDefinitions: getDefs } = require("./tools");
    return getDefs();
}
// Allow running as standalone process
if (require.main === module) {
    const args = process.argv.slice(2);
    let workspace = process.cwd();
    const wsIndex = args.indexOf("--workspace");
    if (wsIndex !== -1 && args[wsIndex + 1]) {
        workspace = args[wsIndex + 1];
    }
    runStdioServer(workspace);
}
//# sourceMappingURL=server.js.map