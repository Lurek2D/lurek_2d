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
exports.register = register;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const LUA_SELECTOR = {
    scheme: "file",
    language: "lua",
};
// ── Graph builder ─────────────────────────────────────────
/**
 * Parse a Lua file for require() calls.
 */
function parseRequires(document) {
    const requires = [];
    const text = document.getText();
    const regex = /\brequire\s*\(\s*["']([^"']+)["']\s*\)/g;
    let match;
    while ((match = regex.exec(text)) !== null) {
        const moduleName = match[1];
        const startOffset = match.index;
        const endOffset = match.index + match[0].length;
        const startPos = document.positionAt(startOffset);
        const endPos = document.positionAt(endOffset);
        requires.push({
            moduleName,
            range: new vscode.Range(startPos, endPos),
        });
    }
    return requires;
}
/**
 * Resolve a Lua module name to a file URI relative to workspace.
 */
function resolveModule(moduleName, workspaceFolder) {
    // Lua module resolution: replace dots with path separator
    const relativePath = moduleName.replace(/\./g, "/");
    const candidates = [
        `${relativePath}.lua`,
        `${relativePath}/init.lua`,
    ];
    for (const candidate of candidates) {
        const uri = vscode.Uri.joinPath(workspaceFolder, candidate);
        return uri; // Return candidate; actual existence checked later
    }
    return undefined;
}
/**
 * Detect cycles in the require graph using DFS with 3-color marking.
 */
function detectCycles(graph) {
    const WHITE = 0, GRAY = 1, BLACK = 2;
    const color = new Map();
    const parent = new Map();
    const cycles = [];
    for (const node of graph.keys()) {
        color.set(node, WHITE);
    }
    function dfs(u, pathStack) {
        color.set(u, GRAY);
        const neighbors = graph.get(u) || [];
        for (const v of neighbors) {
            if (!color.has(v)) {
                // Node not in graph — skip (missing file)
                continue;
            }
            if (color.get(v) === GRAY) {
                // Back edge found — extract cycle
                const cycleStart = pathStack.indexOf(v);
                if (cycleStart >= 0) {
                    const cycle = pathStack.slice(cycleStart);
                    cycle.push(v);
                    cycles.push(cycle);
                }
            }
            else if (color.get(v) === WHITE) {
                parent.set(v, u);
                dfs(v, [...pathStack, v]);
            }
        }
        color.set(u, BLACK);
    }
    for (const node of graph.keys()) {
        if (color.get(node) === WHITE) {
            dfs(node, [node]);
        }
    }
    return cycles;
}
/**
 * Registers the require dependency graph analysis provider.
 */
function register(context) {
    const diagCollection = vscode.languages.createDiagnosticCollection("lurek.requireGraph");
    context.subscriptions.push(diagCollection);
    // File node cache
    const nodeCache = new Map();
    async function buildGraph() {
        const workspaceFolder = vscode.workspace.workspaceFolders?.[0]?.uri;
        if (!workspaceFolder)
            return;
        nodeCache.clear();
        const luaFiles = await vscode.workspace.findFiles("**/*.lua", "**/node_modules/**");
        for (const fileUri of luaFiles) {
            try {
                const doc = await vscode.workspace.openTextDocument(fileUri);
                const requires = parseRequires(doc);
                // Resolve each require
                for (const req of requires) {
                    req.resolvedUri = resolveModule(req.moduleName, workspaceFolder);
                }
                nodeCache.set(fileUri.toString(), { uri: fileUri, requires });
            }
            catch {
                // Skip files that can't be opened
            }
        }
        analyzeGraph(workspaceFolder);
    }
    function analyzeGraph(workspaceFolder) {
        // Build adjacency list
        const adj = new Map();
        const uriByModule = new Map(); // module path → file URI string
        for (const [uriStr, node] of nodeCache) {
            const relPath = path.relative(workspaceFolder.fsPath, node.uri.fsPath).replace(/\\/g, "/").replace(/\.lua$/, "").replace(/\/init$/, "");
            uriByModule.set(relPath, uriStr);
            adj.set(uriStr, []);
        }
        // Link requires to targets
        for (const [uriStr, node] of nodeCache) {
            const edges = [];
            for (const req of node.requires) {
                const modulePath = req.moduleName.replace(/\./g, "/");
                const targetUri = uriByModule.get(modulePath);
                if (targetUri) {
                    edges.push(targetUri);
                }
            }
            adj.set(uriStr, edges);
        }
        // Detect cycles
        const cycles = detectCycles(adj);
        const cycleMembers = new Set();
        for (const cycle of cycles) {
            for (const member of cycle) {
                cycleMembers.add(member);
            }
        }
        // Clear previous diagnostics
        diagCollection.clear();
        // Generate diagnostics
        const allDiags = new Map();
        for (const [uriStr, node] of nodeCache) {
            const diagnostics = [];
            for (const req of node.requires) {
                // Check for missing files
                if (req.resolvedUri) {
                    const modulePath = req.moduleName.replace(/\./g, "/");
                    const targetUri = uriByModule.get(modulePath);
                    if (!targetUri) {
                        const diag = new vscode.Diagnostic(req.range, `Cannot resolve module "${req.moduleName}" — file not found in workspace.`, vscode.DiagnosticSeverity.Warning);
                        diag.code = "lurek.requireMissing";
                        diag.source = "Luna Require Graph";
                        diagnostics.push(diag);
                    }
                }
                // Check if this require is part of a cycle
                const modulePath = req.moduleName.replace(/\./g, "/");
                const targetUri = uriByModule.get(modulePath);
                if (targetUri && cycleMembers.has(uriStr) && cycleMembers.has(targetUri)) {
                    // Find the actual cycle containing both
                    for (const cycle of cycles) {
                        if (cycle.includes(uriStr) && cycle.includes(targetUri)) {
                            const cycleNames = cycle.map((u) => {
                                const n = nodeCache.get(u);
                                if (!n)
                                    return "?";
                                return path.basename(n.uri.fsPath, ".lua");
                            });
                            const diag = new vscode.Diagnostic(req.range, `Circular dependency detected: ${cycleNames.join(" → ")}`, vscode.DiagnosticSeverity.Warning);
                            diag.code = "lurek.requireCycle";
                            diag.source = "Luna Require Graph";
                            diagnostics.push(diag);
                            break;
                        }
                    }
                }
            }
            if (diagnostics.length > 0) {
                allDiags.set(uriStr, diagnostics);
            }
        }
        for (const [uriStr, diags] of allDiags) {
            const node = nodeCache.get(uriStr);
            if (node) {
                diagCollection.set(node.uri, diags);
            }
        }
    }
    // Build graph on activation
    buildGraph();
    // Rebuild on file save
    context.subscriptions.push(vscode.workspace.onDidSaveTextDocument((doc) => {
        if (doc.languageId === "lua") {
            buildGraph();
        }
    }), vscode.workspace.onDidCreateFiles(() => buildGraph()), vscode.workspace.onDidDeleteFiles(() => buildGraph()));
}
//# sourceMappingURL=requireGraph.js.map