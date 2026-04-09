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
exports.LuaDebugConfigurationProvider = exports.LuaDebugAdapterFactory = void 0;
exports.register = register;
const vscode = __importStar(require("vscode"));
const luaDebugSession_js_1 = require("./luaDebugSession.js");
class LuaDebugAdapterFactory {
    createDebugAdapterDescriptor(_session, _executable) {
        return new vscode.DebugAdapterInlineImplementation(new luaDebugSession_js_1.LuaDebugSession());
    }
}
exports.LuaDebugAdapterFactory = LuaDebugAdapterFactory;
class LuaDebugConfigurationProvider {
    resolveDebugConfiguration(_folder, config, _token) {
        if (!config.type) {
            config.type = "luna";
        }
        if (!config.request) {
            config.request = "launch";
        }
        if (!config.name) {
            config.name = "Luna2D: Debug Game";
        }
        if (!config.program) {
            config.program = "${workspaceFolder}";
        }
        if (!config.luaVersion) {
            config.luaVersion = vscode.workspace
                .getConfiguration("luna")
                .get("luaVersion", "luajit");
        }
        if (config.stopOnEntry === undefined) {
            config.stopOnEntry = false;
        }
        if (!config.debugPort) {
            config.debugPort = 8172;
        }
        return config;
    }
    provideDebugConfigurations(_folder) {
        return [
            {
                type: "luna",
                request: "launch",
                name: "Luna2D: Debug Game",
                program: "${workspaceFolder}",
                stopOnEntry: false,
            },
            {
                type: "luna",
                request: "attach",
                name: "Luna2D: Attach to Running",
                debugPort: 8172,
            },
        ];
    }
}
exports.LuaDebugConfigurationProvider = LuaDebugConfigurationProvider;
function register(context) {
    const factory = new LuaDebugAdapterFactory();
    const configProvider = new LuaDebugConfigurationProvider();
    context.subscriptions.push(vscode.debug.registerDebugAdapterDescriptorFactory("luna", factory), vscode.debug.registerDebugConfigurationProvider("luna", configProvider));
}
//# sourceMappingURL=luaDebugAdapter.js.map