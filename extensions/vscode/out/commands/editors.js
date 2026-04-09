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
exports.registerEditorCommands = registerEditorCommands;
const vscode = __importStar(require("vscode"));
const tileMapEditor_js_1 = require("../editors/tileMapEditor.js");
const sceneFlowEditor_js_1 = require("../editors/sceneFlowEditor.js");
const entityEditor_js_1 = require("../editors/entityEditor.js");
const pixelArtEditor_js_1 = require("../editors/pixelArtEditor.js");
const particleEditor_js_1 = require("../editors/particleEditor.js");
const dialogEditor_js_1 = require("../editors/dialogEditor.js");
const databaseEditor_js_1 = require("../editors/databaseEditor.js");
const procMapEditor_js_1 = require("../editors/procMapEditor.js");
const questTreeEditor_js_1 = require("../editors/questTreeEditor.js");
const guiWidgetEditor_js_1 = require("../editors/guiWidgetEditor.js");
const aiBehaviorEditor_js_1 = require("../editors/aiBehaviorEditor.js");
const graphEditor_js_1 = require("../editors/graphEditor.js");
const tilemapScriptEditor_js_1 = require("../editors/tilemapScriptEditor.js");
const voxelEditor_js_1 = require("../editors/voxelEditor.js");
const testRunnerEditor_js_1 = require("../editors/testRunnerEditor.js");
const apiReferenceEditor_js_1 = require("../editors/apiReferenceEditor.js");
const postfxOverlayEditor_js_1 = require("../editors/postfxOverlayEditor.js");
const soundDspEditor_js_1 = require("../editors/soundDspEditor.js");
const spriteAnimEditor_js_1 = require("../editors/spriteAnimEditor.js");
const tilesetEditor_js_1 = require("../editors/tilesetEditor.js");
const audioMixerEditor_js_1 = require("../editors/audioMixerEditor.js");
const colorPaletteEditor_js_1 = require("../editors/colorPaletteEditor.js");
const inputMapperEditor_js_1 = require("../editors/inputMapperEditor.js");
const timelineEditor_js_1 = require("../editors/timelineEditor.js");
const shaderPreviewEditor_js_1 = require("../editors/shaderPreviewEditor.js");
const fontPreviewEditor_js_1 = require("../editors/fontPreviewEditor.js");
const localizationEditor_js_1 = require("../editors/localizationEditor.js");
const physicsMaterialsEditor_js_1 = require("../editors/physicsMaterialsEditor.js");
const worldMapEditor_js_1 = require("../editors/worldMapEditor.js");
const apiCoverageEditor_js_1 = require("../editors/apiCoverageEditor.js");
const EDITORS = [
    { id: "tileMap", open: (ctx) => tileMapEditor_js_1.TileMapEditor.open(ctx) },
    { id: "sceneFlow", open: (ctx) => sceneFlowEditor_js_1.SceneFlowEditor.open(ctx) },
    { id: "entity", open: (ctx) => entityEditor_js_1.EntityEditor.open(ctx) },
    { id: "pixelArt", open: (ctx) => pixelArtEditor_js_1.PixelArtEditor.open(ctx) },
    { id: "particle", open: (ctx) => particleEditor_js_1.ParticleEditor.open(ctx) },
    { id: "dialog", open: (ctx) => dialogEditor_js_1.DialogEditor.open(ctx) },
    { id: "database", open: (ctx) => databaseEditor_js_1.DatabaseEditor.open(ctx) },
    { id: "procMap", open: (ctx) => procMapEditor_js_1.ProcMapEditor.open(ctx) },
    { id: "questTree", open: (ctx) => questTreeEditor_js_1.QuestTreeEditor.open(ctx) },
    { id: "guiWidget", open: (ctx) => guiWidgetEditor_js_1.GuiWidgetEditor.open(ctx) },
    { id: "aiBehavior", open: (ctx) => aiBehaviorEditor_js_1.AiBehaviorEditor.open(ctx) },
    { id: "graph", open: (ctx) => graphEditor_js_1.GraphEditor.open(ctx) },
    { id: "tilemapScript", open: (ctx) => tilemapScriptEditor_js_1.TilemapScriptEditor.open(ctx) },
    { id: "voxel", open: (ctx) => voxelEditor_js_1.VoxelEditor.open(ctx) },
    { id: "testRunner", open: (ctx) => testRunnerEditor_js_1.TestRunnerEditor.open(ctx) },
    { id: "apiReference", open: (ctx) => apiReferenceEditor_js_1.ApiReferenceEditor.open(ctx) },
    { id: "postfxOverlay", open: (ctx) => postfxOverlayEditor_js_1.PostFxOverlayEditor.open(ctx) },
    { id: "soundDsp", open: (ctx) => soundDspEditor_js_1.SoundDspEditor.open(ctx) },
    { id: "spriteAnim", open: (ctx) => spriteAnimEditor_js_1.SpriteAnimEditor.open(ctx) },
    { id: "tileset", open: (ctx) => tilesetEditor_js_1.TilesetEditor.open(ctx) },
    { id: "audioMixer", open: (ctx) => audioMixerEditor_js_1.AudioMixerEditor.open(ctx) },
    { id: "colorPalette", open: (ctx) => colorPaletteEditor_js_1.ColorPaletteEditor.open(ctx) },
    { id: "inputMapper", open: (ctx) => inputMapperEditor_js_1.InputMapperEditor.open(ctx) },
    { id: "timeline", open: (ctx) => timelineEditor_js_1.TimelineEditor.open(ctx) },
    { id: "shaderPreview", open: (ctx) => shaderPreviewEditor_js_1.ShaderPreviewEditor.open(ctx) },
    { id: "fontPreview", open: (ctx) => fontPreviewEditor_js_1.FontPreviewEditor.open(ctx) },
    { id: "localization", open: (ctx) => localizationEditor_js_1.LocalizationEditor.open(ctx) },
    { id: "physicsMaterials", open: (ctx) => physicsMaterialsEditor_js_1.PhysicsMaterialsEditor.open(ctx) },
    { id: "worldMap", open: (ctx) => worldMapEditor_js_1.WorldMapEditor.open(ctx) },
    { id: "apiCoverage", open: (ctx) => apiCoverageEditor_js_1.ApiCoverageEditor.open(ctx) },
];
/**
 * Registers all editor commands and returns the disposables.
 */
function registerEditorCommands(context) {
    return EDITORS.map((entry) => vscode.commands.registerCommand(`luna.editor.${entry.id}`, () => entry.open(context)));
}
//# sourceMappingURL=editors.js.map