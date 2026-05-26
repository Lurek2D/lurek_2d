/**
 * Unit tests for MCP tool handlers.
 *
 * Tests the tool handler factories from src/mcp/tools.ts with mocked
 * filesystem and service dependencies.
 */
import * as assert from "assert";
import * as fs from "fs";
import * as path from "path";
import {
  handleGetApiDoc,
  handleListExamples,
  handleGetModuleInfo,
  handleInspectLuaFile,
  handleGetTestCoverage,
  handleGetProjectStructure,
} from "../../mcp/tools";

/* eslint-disable @typescript-eslint/no-explicit-any */

const WORKSPACE_ROOT = "/mock/workspace";

// ── Stub helpers ────────────────────────────────────────────

type AnyFn = (...args: any[]) => any;

function stub<T extends object, K extends keyof T>(
  obj: T,
  method: K,
  impl: AnyFn,
): { restore: () => void } {
  const original = obj[method];
  (obj as any)[method] = impl;
  return { restore: () => { (obj as any)[method] = original; } };
}

// ── lurek2d.getApiDoc ───────────────────────────────────────

suite("MCP Tools — lurek2d.getApiDoc", () => {
  const stubs: { restore: () => void }[] = [];

  teardown(() => {
    stubs.forEach(s => s.restore());
    stubs.length = 0;
  });

  test("returns documentation for a valid function name", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", () =>
      "--- @summary Draw a sprite\nfunction lurek.render.draw(sprite, x, y) end\n\n" +
      "--- @summary Clear the screen\nfunction lurek.render.clear() end\n"
    ));

    const handler = handleGetApiDoc(WORKSPACE_ROOT);
    const result = await handler({ query: "lurek.render.draw" });

    assert.ok(result.includes("lurek.render.draw"));
  });

  test("returns error message for unknown function", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", () =>
      "--- @summary Draw a sprite\nfunction lurek.render.draw(sprite, x, y) end\n"
    ));

    const handler = handleGetApiDoc(WORKSPACE_ROOT);
    const result = await handler({ query: "lurek.nonexistent.thing" });

    assert.ok(result.includes("No documentation found"));
  });

  test("returns markdown formatted content for .lua API file", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", () =>
      "--- @summary Draw a sprite\nfunction lurek.render.draw(sprite, x, y) end\n"
    ));

    const handler = handleGetApiDoc(WORKSPACE_ROOT);
    const result = await handler({ query: "lurek.render.draw" });

    assert.ok(result.includes("```lua"));
  });

  test("returns error when query parameter is missing", async () => {
    const handler = handleGetApiDoc(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("Error"));
  });
});

// ── lurek2d.listExamples ────────────────────────────────────

suite("MCP Tools — lurek2d.listExamples", () => {
  const stubs: { restore: () => void }[] = [];

  teardown(() => {
    stubs.forEach(s => s.restore());
    stubs.length = 0;
  });

  test("returns non-empty list of example directories", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "hello_world", isDirectory: () => true },
      { name: "platformer", isDirectory: () => true },
    ]));

    const handler = handleListExamples(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("hello_world"));
    assert.ok(result.includes("platformer"));
  });

  test("each entry is a directory name excluding files", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "demo_game", isDirectory: () => true },
      { name: "README.md", isDirectory: () => false },
    ]));

    const handler = handleListExamples(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("demo_game"));
    assert.ok(!result.includes("README.md"));
  });

  test("returns message when no examples exist", async () => {
    stubs.push(stub(fs, "existsSync", () => false));

    const handler = handleListExamples(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("No showcase games found"));
  });
});

// ── lurek2d.getModuleInfo ───────────────────────────────────

suite("MCP Tools — lurek2d.getModuleInfo", () => {
  const stubs: { restore: () => void }[] = [];

  teardown(() => {
    stubs.forEach(s => s.restore());
    stubs.length = 0;
  });

  test("returns tier info for a known module", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "mod.rs", isDirectory: () => false },
      { name: "pipeline.rs", isDirectory: () => false },
    ]));
    stubs.push(stub(fs, "readFileSync", () => "use crate::math;\nuse crate::color;\n"));

    const handler = handleGetModuleInfo(WORKSPACE_ROOT);
    const result = await handler({ module: "render" });
    const parsed = JSON.parse(result);

    assert.strictEqual(parsed.tier, "Platform Services");
  });

  test("returns error for unknown module name", async () => {
    stubs.push(stub(fs, "existsSync", (p: string) => !p.includes("nonexistent_module")));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "render", isDirectory: () => true },
      { name: "audio", isDirectory: () => true },
    ]));

    const handler = handleGetModuleInfo(WORKSPACE_ROOT);
    const result = await handler({ module: "nonexistent_module" });

    assert.ok(result.includes("not found"));
  });

  test("response includes apiFunctions array", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "mod.rs", isDirectory: () => false },
    ]));
    stubs.push(stub(fs, "readFileSync", (p: string) => {
      if (typeof p === "string" && p.includes("_api.rs")) {
        return '"lurek.render.draw"\n"lurek.render.clear"\n';
      }
      if (typeof p === "string" && p.includes("lurek-api.json")) {
        return JSON.stringify({ modules: [] });
      }
      return "";
    }));

    const handler = handleGetModuleInfo(WORKSPACE_ROOT);
    const result = await handler({ module: "render" });
    const parsed = JSON.parse(result);

    assert.ok(Array.isArray(parsed.apiFunctions));
  });

  test("returns error when module parameter is missing", async () => {
    const handler = handleGetModuleInfo(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("Error"));
  });
});

// ── lurek2d.inspectLuaFile ──────────────────────────────────

suite("MCP Tools — lurek2d.inspectLuaFile", () => {
  const stubs: { restore: () => void }[] = [];

  teardown(() => {
    stubs.forEach(s => s.restore());
    stubs.length = 0;
  });

  test("returns functions, requires, and callbacks for a valid Lua file", async () => {
    const filePath = "content/examples/test.lua";
    const resolved = WORKSPACE_ROOT + "/content/examples/test.lua";
    stubs.push(stub(path, "resolve", () => resolved));
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", () =>
      'local utils = require("utils")\n\n' +
      "function lurek.update(dt)\n  print(dt)\nend\n\n" +
      "local function helper(x, y)\n  return x + y\nend\n"
    ));

    const handler = handleInspectLuaFile(WORKSPACE_ROOT);
    const result = await handler({ path: filePath });
    const parsed = JSON.parse(result);

    assert.ok(Array.isArray(parsed.functions));
    assert.ok(Array.isArray(parsed.requires));
    assert.ok(Array.isArray(parsed.callbacks));
  });

  test("returns error for non-existent file path", async () => {
    const resolved = WORKSPACE_ROOT + "/content/examples/missing.lua";
    stubs.push(stub(path, "resolve", () => resolved));
    stubs.push(stub(fs, "existsSync", () => false));

    const handler = handleInspectLuaFile(WORKSPACE_ROOT);
    const result = await handler({ path: "content/examples/missing.lua" });

    assert.ok(result.includes("File not found"));
  });

  test("rejects paths with directory traversal", async () => {
    stubs.push(stub(path, "resolve", () => "/etc/passwd"));

    const handler = handleInspectLuaFile(WORKSPACE_ROOT);
    const result = await handler({ path: "../../../etc/passwd" });

    assert.ok(result.includes("Error: file path must be within the workspace"));
  });

  test("returns error when path parameter is missing", async () => {
    const handler = handleInspectLuaFile(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("Error"));
  });
});

// ── lurek2d.getTestCoverage ─────────────────────────────────

suite("MCP Tools — lurek2d.getTestCoverage", () => {
  const stubs: { restore: () => void }[] = [];

  teardown(() => {
    stubs.forEach(s => s.restore());
    stubs.length = 0;
  });

  test("returns total and covered counts", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", (p: string) => {
      if (typeof p === "string" && p.includes("lurek-api.json")) {
        return JSON.stringify({
          modules: [{
            name: "render",
            functions: [
              { name: "draw", fullPath: "lurek.render.draw" },
              { name: "clear", fullPath: "lurek.render.clear" },
            ],
          }],
        });
      }
      return "lurek.render.draw(sprite, 10, 20)\n";
    }));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "test_render.lua", isDirectory: () => false },
    ]));

    const handler = handleGetTestCoverage(WORKSPACE_ROOT);
    const result = await handler({});
    const parsed = JSON.parse(result);

    assert.strictEqual(typeof parsed.summary.totalFunctions, "number");
    assert.strictEqual(typeof parsed.summary.coveredByTests, "number");
    assert.ok(parsed.summary.totalFunctions >= parsed.summary.coveredByTests);
  });

  test("uncovered array contains only valid function names", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", (p: string) => {
      if (typeof p === "string" && p.includes("lurek-api.json")) {
        return JSON.stringify({
          modules: [{
            name: "audio",
            functions: [
              { name: "play", fullPath: "lurek.audio.play" },
              { name: "stop", fullPath: "lurek.audio.stop" },
            ],
          }],
        });
      }
      return "-- empty test file\n";
    }));
    stubs.push(stub(fs, "readdirSync", () => [
      { name: "test_audio.lua", isDirectory: () => false },
    ]));

    const handler = handleGetTestCoverage(WORKSPACE_ROOT);
    const result = await handler({});
    const parsed = JSON.parse(result);
    const audioModule = parsed.modules.find((m: { module: string }) => m.module === "audio");

    assert.ok(Array.isArray(audioModule.uncovered));
    for (const fn of audioModule.uncovered) {
      assert.ok(fn.startsWith("lurek."));
    }
  });

  test("works with module filter parameter", async () => {
    stubs.push(stub(fs, "existsSync", () => true));
    stubs.push(stub(fs, "readFileSync", (p: string) => {
      if (typeof p === "string" && p.includes("lurek-api.json")) {
        return JSON.stringify({
          modules: [
            { name: "render", functions: [{ name: "draw", fullPath: "lurek.render.draw" }] },
            { name: "audio", functions: [{ name: "play", fullPath: "lurek.audio.play" }] },
          ],
        });
      }
      return "";
    }));
    stubs.push(stub(fs, "readdirSync", () => []));

    const handler = handleGetTestCoverage(WORKSPACE_ROOT);
    const result = await handler({ module: "audio" });
    const parsed = JSON.parse(result);

    assert.strictEqual(parsed.modules.length, 1);
    assert.strictEqual(parsed.modules[0].module, "audio");
  });

  test("returns error when lurek-api.json is missing", async () => {
    stubs.push(stub(fs, "existsSync", () => false));

    const handler = handleGetTestCoverage(WORKSPACE_ROOT);
    const result = await handler({});

    assert.ok(result.includes("Error"));
  });
});

// ── lurek2d.getProjectStructure ─────────────────────────────

suite("MCP Tools — lurek2d.getProjectStructure", () => {
  const stubs: { restore: () => void }[] = [];

  teardown(() => {
    stubs.forEach(s => s.restore());
    stubs.length = 0;
  });

  test("returns categorized file tree", async () => {
    stubs.push(stub(fs, "existsSync", (p: string) => {
      if (typeof p === "string" && (p.includes("content") || p.includes("assets"))) return true;
      return false;
    }));
    stubs.push(stub(fs, "readdirSync", (dir: string) => {
      if (typeof dir === "string" && dir.includes("content")) {
        return [
          { name: "main.lua", isDirectory: () => false },
          { name: "bg.png", isDirectory: () => false },
          { name: "music.ogg", isDirectory: () => false },
          { name: "conf.toml", isDirectory: () => false },
        ];
      }
      return [];
    }));

    const handler = handleGetProjectStructure(WORKSPACE_ROOT);
    const result = await handler({});
    const parsed = JSON.parse(result);

    assert.ok(parsed.categories !== undefined);
    assert.ok(typeof parsed.totalFiles === "number");
  });

  test("categories include scripts, images, audio, configs", async () => {
    stubs.push(stub(fs, "existsSync", (p: string) => {
      if (typeof p === "string" && (p.includes("content") || p.includes("assets"))) return true;
      return false;
    }));
    stubs.push(stub(fs, "readdirSync", (dir: string) => {
      if (typeof dir === "string" && dir.includes("content")) {
        return [
          { name: "game.lua", isDirectory: () => false },
          { name: "sprite.png", isDirectory: () => false },
          { name: "sfx.wav", isDirectory: () => false },
          { name: "settings.toml", isDirectory: () => false },
        ];
      }
      return [];
    }));

    const handler = handleGetProjectStructure(WORKSPACE_ROOT);
    const result = await handler({});
    const parsed = JSON.parse(result);

    assert.ok("scripts" in parsed.categories);
    assert.ok("images" in parsed.categories);
    assert.ok("audio" in parsed.categories);
    assert.ok("configs" in parsed.categories);
  });

  test("returns empty structure when no content exists", async () => {
    stubs.push(stub(fs, "existsSync", () => false));

    const handler = handleGetProjectStructure(WORKSPACE_ROOT);
    const result = await handler({});
    const parsed = JSON.parse(result);

    assert.strictEqual(parsed.totalFiles, 0);
  });
});
