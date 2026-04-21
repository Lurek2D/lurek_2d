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
exports.LuaDebugSession = void 0;
const debugadapter_1 = require("@vscode/debugadapter");
const net = __importStar(require("net"));
const path = __importStar(require("path"));
const child_process_1 = require("child_process");
const fs = __importStar(require("fs"));
const THREAD_ID = 1;
const MAX_CONNECT_RETRIES = 3;
const RETRY_DELAY_MS = 500;
const DEFAULT_DEBUG_PORT = 8172;
class LuaDebugSession extends debugadapter_1.LoggingDebugSession {
    socket = null;
    engineProcess = null;
    breakpoints = new Map();
    variablesMap = new Map();
    nextVariableRef = 1;
    pendingRequests = new Map();
    nextRequestId = 1;
    receiveBuffer = "";
    gamePath = "";
    debugPort = DEFAULT_DEBUG_PORT;
    loadedSources = [];
    constructor() {
        super("lurek-debug.log");
        this.setDebuggerLinesStartAt1(true);
        this.setDebuggerColumnsStartAt1(true);
    }
    // ── Initialization ──────────────────────────────────────
    initializeRequest(response, _args) {
        response.body = {
            supportsConfigurationDoneRequest: true,
            supportsFunctionBreakpoints: false,
            supportsConditionalBreakpoints: true,
            supportsHitConditionalBreakpoints: true,
            supportsEvaluateForHovers: true,
            supportsStepBack: false,
            supportsSetVariable: true,
            supportsRestartFrame: false,
            supportsGotoTargetsRequest: false,
            supportsStepInTargetsRequest: false,
            supportsCompletionsRequest: true,
            supportsModulesRequest: false,
            supportsExceptionOptions: false,
            supportsValueFormattingOptions: false,
            supportsExceptionInfoRequest: false,
            supportTerminateDebuggee: true,
            supportsDelayedStackTraceLoading: false,
            supportsLoadedSourcesRequest: true,
            supportsLogPoints: true,
            supportsTerminateThreadsRequest: false,
            supportsSetExpression: false,
            supportsTerminateRequest: true,
            supportsDataBreakpoints: false,
            supportsReadMemoryRequest: false,
            supportsDisassembleRequest: false,
            supportsBreakpointLocationsRequest: true,
            supportsClipboardContext: false,
            supportsExceptionFilterOptions: false,
            supportsSteppingGranularity: false,
            supportsInstructionBreakpoints: false,
        };
        this.sendResponse(response);
        this.sendEvent(new debugadapter_1.InitializedEvent());
    }
    // ── Launch / Attach ─────────────────────────────────────
    async launchRequest(response, args) {
        this.gamePath = args.program;
        this.debugPort = args.debugPort ?? DEFAULT_DEBUG_PORT;
        const stopOnEntry = args.stopOnEntry ?? false;
        const engineBinary = this.findEngineBinary(args.enginePath);
        if (!engineBinary) {
            this.sendErrorResponse(response, 1001, "Luna2D engine not found. Set 'lurek.lunaPath' in settings or ensure luna2d is on PATH.");
            return;
        }
        const spawnArgs = [
            `--debug-port=${this.debugPort}`,
            this.gamePath,
            ...(args.args ?? []),
        ];
        this.log(`Launching: ${engineBinary} ${spawnArgs.join(" ")}`);
        try {
            this.engineProcess = (0, child_process_1.spawn)(engineBinary, spawnArgs, {
                cwd: path.dirname(this.gamePath),
                stdio: ["ignore", "pipe", "pipe"],
            });
            this.engineProcess.stdout?.on("data", (data) => {
                this.sendEvent(new debugadapter_1.OutputEvent(data.toString(), "stdout"));
            });
            this.engineProcess.stderr?.on("data", (data) => {
                this.sendEvent(new debugadapter_1.OutputEvent(data.toString(), "stderr"));
            });
            this.engineProcess.on("exit", (code) => {
                this.log(`Engine exited with code ${code}`);
                this.sendEvent(new debugadapter_1.TerminatedEvent());
            });
            this.engineProcess.on("error", (err) => {
                this.sendEvent(new debugadapter_1.OutputEvent(`Engine error: ${err.message}\n`, "stderr"));
                this.sendEvent(new debugadapter_1.TerminatedEvent());
            });
            await this.connectToEngine(this.debugPort);
            if (stopOnEntry) {
                await this.sendToEngine("pause");
            }
            this.sendResponse(response);
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            this.sendErrorResponse(response, 1002, `Failed to launch: ${message}`);
        }
    }
    async attachRequest(response, args) {
        this.debugPort = args.debugPort ?? DEFAULT_DEBUG_PORT;
        try {
            await this.connectToEngine(this.debugPort);
            this.sendResponse(response);
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            this.sendErrorResponse(response, 1003, `Failed to attach: ${message}`);
        }
    }
    configurationDoneRequest(response, _args) {
        this.sendResponse(response);
    }
    async disconnectRequest(response, args) {
        if (args.terminateDebuggee !== false && this.engineProcess) {
            try {
                await this.sendToEngine("terminate");
            }
            catch {
                // engine may already be gone
            }
        }
        this.cleanup();
        this.sendResponse(response);
    }
    async terminateRequest(response, _args) {
        try {
            await this.sendToEngine("terminate");
        }
        catch {
            // best effort
        }
        this.cleanup();
        this.sendResponse(response);
    }
    // ── Breakpoints ─────────────────────────────────────────
    async setBreakPointsRequest(response, args) {
        const sourcePath = args.source.path ?? "";
        const clientLines = args.lines ?? [];
        const relativePath = this.toRelativePath(sourcePath);
        try {
            const engineResp = await this.sendToEngine("setBreakpoints", {
                file: relativePath,
                lines: clientLines,
            });
            const bps = clientLines.map((line, idx) => {
                const bp = new debugadapter_1.Breakpoint(true, line);
                bp.id = idx + 1;
                if (engineResp.body && Array.isArray(engineResp.body.breakpoints)) {
                    const engineBp = engineResp.body.breakpoints[idx];
                    if (engineBp) {
                        bp.verified = engineBp.verified;
                        if (engineBp.line !== undefined) {
                            bp.line = engineBp.line;
                        }
                    }
                }
                return bp;
            });
            this.breakpoints.set(sourcePath, bps);
            if (!this.loadedSources.find((s) => s.path === sourcePath)) {
                this.loadedSources.push(new debugadapter_1.Source(path.basename(sourcePath), sourcePath));
            }
            response.body = { breakpoints: bps };
        }
        catch {
            // Offline — report all as unverified
            const bps = clientLines.map((line, idx) => {
                const bp = new debugadapter_1.Breakpoint(false, line);
                bp.id = idx + 1;
                return bp;
            });
            this.breakpoints.set(sourcePath, bps);
            response.body = { breakpoints: bps };
        }
        this.sendResponse(response);
    }
    breakpointLocationsRequest(response, args) {
        // Report that breakpoints can be set on any requested line
        const startLine = args.line;
        const endLine = args.endLine ?? startLine;
        const locations = [];
        for (let line = startLine; line <= endLine; line++) {
            locations.push({ line });
        }
        response.body = { breakpoints: locations };
        this.sendResponse(response);
    }
    // ── Threads ─────────────────────────────────────────────
    threadsRequest(response) {
        response.body = {
            threads: [new debugadapter_1.Thread(THREAD_ID, "Luna Main")],
        };
        this.sendResponse(response);
    }
    // ── Stack Trace ─────────────────────────────────────────
    async stackTraceRequest(response, args) {
        try {
            const engineResp = await this.sendToEngine("stackTrace");
            const frames = [];
            if (engineResp.body && Array.isArray(engineResp.body.frames)) {
                const engineFrames = engineResp.body.frames;
                const startFrame = args.startFrame ?? 0;
                const levels = args.levels ?? engineFrames.length;
                const endFrame = Math.min(startFrame + levels, engineFrames.length);
                for (let i = startFrame; i < endFrame; i++) {
                    const ef = engineFrames[i];
                    const fullPath = this.toAbsolutePath(ef.file);
                    const source = new debugadapter_1.Source(path.basename(ef.file), fullPath);
                    frames.push(new debugadapter_1.StackFrame(i, ef.name, source, ef.line, ef.column ?? 1));
                }
            }
            response.body = {
                stackFrames: frames,
                totalFrames: engineResp.body?.frames?.length ?? frames.length,
            };
        }
        catch {
            response.body = { stackFrames: [], totalFrames: 0 };
        }
        this.sendResponse(response);
    }
    // ── Scopes ──────────────────────────────────────────────
    async scopesRequest(response, args) {
        try {
            const engineResp = await this.sendToEngine("scopes", {
                frameId: args.frameId,
            });
            const scopes = [];
            if (engineResp.body && Array.isArray(engineResp.body.scopes)) {
                for (const s of engineResp.body.scopes) {
                    scopes.push(new debugadapter_1.Scope(s.name, s.variablesReference, s.expensive ?? false));
                }
            }
            else {
                // Default scopes: locals and upvalues
                const localsRef = this.nextVariableRef++;
                const upvaluesRef = this.nextVariableRef++;
                scopes.push(new debugadapter_1.Scope("Locals", localsRef, false));
                scopes.push(new debugadapter_1.Scope("Upvalues", upvaluesRef, false));
            }
            response.body = { scopes };
        }
        catch {
            response.body = { scopes: [] };
        }
        this.sendResponse(response);
    }
    // ── Variables ───────────────────────────────────────────
    async variablesRequest(response, args) {
        try {
            const cached = this.variablesMap.get(args.variablesReference);
            if (cached) {
                response.body = { variables: cached };
                this.sendResponse(response);
                return;
            }
            const engineResp = await this.sendToEngine("variables", {
                variablesReference: args.variablesReference,
            });
            const variables = [];
            if (engineResp.body && Array.isArray(engineResp.body.variables)) {
                for (const v of engineResp.body.variables) {
                    let varRef = 0;
                    if (v.children && v.children.length > 0) {
                        varRef = this.nextVariableRef++;
                        const childVars = v.children.map((c) => {
                            let childRef = 0;
                            if (c.children && c.children.length > 0) {
                                childRef = this.nextVariableRef++;
                                this.variablesMap.set(childRef, c.children.map((gc) => new debugadapter_1.Variable(gc.name, gc.value, 0)));
                            }
                            return new debugadapter_1.Variable(c.name, c.value, childRef);
                        });
                        this.variablesMap.set(varRef, childVars);
                    }
                    else if (v.variablesReference) {
                        varRef = v.variablesReference;
                    }
                    variables.push(new debugadapter_1.Variable(v.name, v.value, varRef));
                }
            }
            this.variablesMap.set(args.variablesReference, variables);
            response.body = { variables };
        }
        catch {
            response.body = { variables: [] };
        }
        this.sendResponse(response);
    }
    async setVariableRequest(response, args) {
        try {
            const engineResp = await this.sendToEngine("setVariable", {
                variablesReference: args.variablesReference,
                name: args.name,
                value: args.value,
            });
            response.body = {
                value: engineResp.body?.value ?? args.value,
            };
            // Invalidate cached variables
            this.variablesMap.delete(args.variablesReference);
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            this.sendErrorResponse(response, 1010, `Failed to set variable: ${message}`);
            return;
        }
        this.sendResponse(response);
    }
    // ── Execution Control ───────────────────────────────────
    async continueRequest(response, _args) {
        this.variablesMap.clear();
        try {
            await this.sendToEngine("continue");
        }
        catch {
            // best effort
        }
        response.body = { allThreadsContinued: true };
        this.sendResponse(response);
    }
    async nextRequest(response, _args) {
        this.variablesMap.clear();
        try {
            await this.sendToEngine("next");
        }
        catch {
            // best effort
        }
        this.sendResponse(response);
    }
    async stepInRequest(response, _args) {
        this.variablesMap.clear();
        try {
            await this.sendToEngine("stepIn");
        }
        catch {
            // best effort
        }
        this.sendResponse(response);
    }
    async stepOutRequest(response, _args) {
        this.variablesMap.clear();
        try {
            await this.sendToEngine("stepOut");
        }
        catch {
            // best effort
        }
        this.sendResponse(response);
    }
    async pauseRequest(response, _args) {
        try {
            await this.sendToEngine("pause");
        }
        catch {
            // best effort
        }
        this.sendResponse(response);
    }
    // ── Evaluate ────────────────────────────────────────────
    async evaluateRequest(response, args) {
        try {
            const engineResp = await this.sendToEngine("evaluate", {
                expression: args.expression,
                frameId: args.frameId ?? 0,
                context: args.context,
            });
            const result = engineResp.body?.result ?? "nil";
            const varRef = engineResp.body?.variablesReference ?? 0;
            response.body = {
                result,
                variablesReference: varRef,
            };
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            response.body = {
                result: `Error: ${message}`,
                variablesReference: 0,
            };
        }
        this.sendResponse(response);
    }
    // ── Completions ─────────────────────────────────────────
    completionsRequest(response, args) {
        const text = args.text;
        const targets = [];
        // Provide lurek.* namespace completions
        if (text.startsWith("lurek.")) {
            const lunaModules = [
                "graphics", "audio", "timer", "keyboard", "mouse", "gamepad",
                "touch", "window", "filesystem", "math", "physics", "system",
                "data", "event", "thread", "scene", "entity", "particle",
            ];
            for (const mod of lunaModules) {
                if (mod.startsWith(text.slice(5))) {
                    targets.push(new debugadapter_1.CompletionItem(mod, 9)); // 9 = Module
                }
            }
        }
        // Basic Lua keywords
        const keywords = [
            "local", "function", "if", "then", "else", "elseif", "end",
            "for", "while", "do", "repeat", "until", "return", "break",
            "in", "not", "and", "or", "true", "false", "nil",
        ];
        for (const kw of keywords) {
            if (kw.startsWith(text)) {
                targets.push(new debugadapter_1.CompletionItem(kw, 14)); // 14 = Keyword
            }
        }
        response.body = { targets };
        this.sendResponse(response);
    }
    // ── Loaded Sources ──────────────────────────────────────
    loadedSourcesRequest(response) {
        response.body = { sources: this.loadedSources };
        this.sendResponse(response);
    }
    // ── TCP Communication ───────────────────────────────────
    connectToEngine(port) {
        return new Promise((resolve, reject) => {
            let retries = 0;
            const attempt = () => {
                const socket = new net.Socket();
                const onError = (err) => {
                    socket.destroy();
                    retries++;
                    if (retries < MAX_CONNECT_RETRIES) {
                        this.log(`Connection attempt ${retries} failed, retrying in ${RETRY_DELAY_MS}ms...`);
                        setTimeout(attempt, RETRY_DELAY_MS);
                    }
                    else {
                        reject(new Error(`Failed to connect to Luna2D engine on port ${port} after ${MAX_CONNECT_RETRIES} attempts: ${err.message}`));
                    }
                };
                socket.once("error", onError);
                socket.connect(port, "127.0.0.1", () => {
                    socket.removeListener("error", onError);
                    this.socket = socket;
                    this.receiveBuffer = "";
                    this.log(`Connected to Luna2D engine on port ${port}`);
                    socket.on("data", (data) => {
                        this.onSocketData(data);
                    });
                    socket.on("error", (err) => {
                        this.sendEvent(new debugadapter_1.OutputEvent(`Engine connection error: ${err.message}\n`, "stderr"));
                        this.cleanup();
                        this.sendEvent(new debugadapter_1.TerminatedEvent());
                    });
                    socket.on("close", () => {
                        this.log("Engine connection closed");
                        this.cleanup();
                        this.sendEvent(new debugadapter_1.TerminatedEvent());
                    });
                    resolve();
                });
            };
            attempt();
        });
    }
    sendToEngine(command, args) {
        return new Promise((resolve, reject) => {
            if (!this.socket || this.socket.destroyed) {
                reject(new Error("Not connected to engine"));
                return;
            }
            const id = this.nextRequestId++;
            const message = JSON.stringify({ id, command, args: args ?? {} });
            const packet = `Content-Length: ${Buffer.byteLength(message)}\r\n\r\n${message}`;
            this.pendingRequests.set(id, { resolve, reject });
            // Timeout after 10 seconds
            const timer = setTimeout(() => {
                this.pendingRequests.delete(id);
                reject(new Error(`Request '${command}' timed out`));
            }, 10_000);
            // Wrap resolve/reject to clear timeout
            const original = this.pendingRequests.get(id);
            this.pendingRequests.set(id, {
                resolve: (resp) => {
                    clearTimeout(timer);
                    original.resolve(resp);
                },
                reject: (err) => {
                    clearTimeout(timer);
                    original.reject(err);
                },
            });
            try {
                this.socket.write(packet);
            }
            catch (err) {
                clearTimeout(timer);
                this.pendingRequests.delete(id);
                reject(err instanceof Error ? err : new Error(String(err)));
            }
        });
    }
    onSocketData(data) {
        this.receiveBuffer += data.toString("utf-8");
        // Process complete messages from the buffer
        while (true) {
            const headerEnd = this.receiveBuffer.indexOf("\r\n\r\n");
            if (headerEnd === -1) {
                break;
            }
            const header = this.receiveBuffer.substring(0, headerEnd);
            const match = /Content-Length:\s*(\d+)/i.exec(header);
            if (!match) {
                // Malformed header — skip past it
                this.receiveBuffer = this.receiveBuffer.substring(headerEnd + 4);
                continue;
            }
            const contentLength = parseInt(match[1], 10);
            const bodyStart = headerEnd + 4;
            if (this.receiveBuffer.length < bodyStart + contentLength) {
                break; // incomplete body
            }
            const body = this.receiveBuffer.substring(bodyStart, bodyStart + contentLength);
            this.receiveBuffer = this.receiveBuffer.substring(bodyStart + contentLength);
            try {
                const message = JSON.parse(body);
                if ("event" in message) {
                    this.handleEngineEvent(message);
                }
                else if ("id" in message) {
                    this.handleEngineResponse(message);
                }
            }
            catch {
                this.log(`Failed to parse engine message: ${body}`);
            }
        }
    }
    handleEngineEvent(event) {
        switch (event.event) {
            case "stopped": {
                const stoppedEvent = new debugadapter_1.StoppedEvent(event.reason ?? "breakpoint", THREAD_ID);
                this.variablesMap.clear();
                this.sendEvent(stoppedEvent);
                break;
            }
            case "output": {
                this.sendEvent(new debugadapter_1.OutputEvent(event.output ?? "", event.category ?? "console"));
                break;
            }
            case "terminated": {
                this.sendEvent(new debugadapter_1.TerminatedEvent());
                break;
            }
            case "breakpointValidated": {
                if (event.id !== undefined && event.verified !== undefined) {
                    // Find and update the breakpoint
                    for (const [, bps] of this.breakpoints) {
                        for (const bp of bps) {
                            if (bp.id === event.id) {
                                bp.verified = event.verified;
                            }
                        }
                    }
                }
                break;
            }
            default:
                this.log(`Unknown engine event: ${event.event}`);
        }
    }
    handleEngineResponse(response) {
        const pending = this.pendingRequests.get(response.id);
        if (pending) {
            this.pendingRequests.delete(response.id);
            if (response.success) {
                pending.resolve(response);
            }
            else {
                pending.reject(new Error(response.error ?? "Unknown engine error"));
            }
        }
    }
    // ── Helpers ─────────────────────────────────────────────
    findEngineBinary(configPath) {
        // 1. Explicitly configured path
        if (configPath && fs.existsSync(configPath)) {
            return configPath;
        }
        // 2. VS Code setting
        const settingsPath = 
        // eslint-disable-next-line @typescript-eslint/no-require-imports
        require("vscode").workspace
            .getConfiguration("lurek")
            .get("lunaPath", "");
        if (settingsPath && fs.existsSync(settingsPath)) {
            return settingsPath;
        }
        // 3. Common install locations (Windows)
        const homeDir = process.env.USERPROFILE ?? process.env.HOME ?? "";
        const candidates = [
            path.join(homeDir, "bin", "lurek.exe"),
            path.join(homeDir, "bin", "luna2d.exe"),
            path.join(homeDir, "bin", "lurek"),
            path.join(homeDir, "bin", "luna2d"),
        ];
        for (const candidate of candidates) {
            if (fs.existsSync(candidate)) {
                return candidate;
            }
        }
        // 4. Rely on PATH
        const pathExe = process.platform === "win32" ? "lurek.exe" : "luna2d";
        const pathDirs = (process.env.PATH ?? "").split(path.delimiter);
        for (const dir of pathDirs) {
            const fullPath = path.join(dir, pathExe);
            if (fs.existsSync(fullPath)) {
                return fullPath;
            }
        }
        return null;
    }
    toRelativePath(absolutePath) {
        if (this.gamePath && absolutePath.startsWith(this.gamePath)) {
            let rel = absolutePath.substring(this.gamePath.length);
            if (rel.startsWith(path.sep) || rel.startsWith("/")) {
                rel = rel.substring(1);
            }
            return rel.replace(/\\/g, "/");
        }
        return path.basename(absolutePath);
    }
    toAbsolutePath(relativePath) {
        if (path.isAbsolute(relativePath)) {
            return relativePath;
        }
        return path.join(this.gamePath, relativePath);
    }
    cleanup() {
        if (this.socket) {
            this.socket.removeAllListeners();
            this.socket.destroy();
            this.socket = null;
        }
        if (this.engineProcess) {
            try {
                this.engineProcess.kill();
            }
            catch {
                // already dead
            }
            this.engineProcess = null;
        }
        // Reject all pending requests
        for (const [, pending] of this.pendingRequests) {
            pending.reject(new Error("Debug session ended"));
        }
        this.pendingRequests.clear();
        this.variablesMap.clear();
    }
    log(message) {
        this.sendEvent(new debugadapter_1.OutputEvent(`[Luna Debug] ${message}\n`, "console"));
    }
}
exports.LuaDebugSession = LuaDebugSession;
//# sourceMappingURL=luaDebugSession.js.map