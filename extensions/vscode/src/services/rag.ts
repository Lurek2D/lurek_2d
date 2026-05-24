import * as child_process from "child_process";
import * as path from "path";

const PYTHON_EXECUTABLE = "python";
const QUERY_SCRIPT = "tools/rag/query.py";
const BUILD_SCRIPT = "tools/rag/build_index.py";

export function execRagQuery(
  workspaceRoot: string,
  query: string,
  profile: "game" | "engine" | "all" = "all",
  timeoutMs = 15_000,
): Promise<string> {
  return new Promise((resolve) => {
    child_process.execFile(
      PYTHON_EXECUTABLE,
      [QUERY_SCRIPT, query, "--profile", profile],
      {
        cwd: workspaceRoot,
        timeout: timeoutMs,
        maxBuffer: 1024 * 1024 * 5, // 5MB buffer for large JSON outputs
        encoding: "utf-8",
      },
      (error, stdout, stderr) => {
        const output = `${stdout || ""}${stderr || ""}`;
        if (error) {
          resolve(`${output}\n[RAG query exit code: ${error.code ?? "unknown"}]`);
          return;
        }
        resolve(output || "(no output)");
      },
    );
  });
}

export function execRagBuildIndex(
  workspaceRoot: string,
  directories: string[] = [],
  timeoutMs = 60_000,
): Promise<string> {
  return new Promise((resolve) => {
    child_process.execFile(
      PYTHON_EXECUTABLE,
      [BUILD_SCRIPT, ...directories],
      {
        cwd: workspaceRoot,
        timeout: timeoutMs,
        maxBuffer: 1024 * 1024 * 5,
        encoding: "utf-8",
      },
      (error, stdout, stderr) => {
        const output = `${stdout || ""}${stderr || ""}`;
        if (error) {
          resolve(`${output}\n[RAG build exit code: ${error.code ?? "unknown"}]`);
          return;
        }
        resolve(output || "Index built successfully.");
      },
    );
  });
}
