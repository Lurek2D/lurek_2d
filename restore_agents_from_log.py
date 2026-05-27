import json
import os

transcript_path = r"C:\Users\tombl\.gemini\antigravity-ide\brain\4e4b242f-b21a-4396-b462-f706464148d5\.system_generated\logs\transcript.jsonl"

file_contents = {}

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            data = json.loads(line)
        except:
            continue
            
        if data.get("type") == "TOOL_CALLS":
            for call in data.get("tool_calls", []):
                if call.get("name") == "default_api:write_to_file":
                    args = call.get("arguments", {})
                    target_file = args.get("TargetFile", "").replace("\\", "/")
                    if ".agents/" in target_file:
                        code_content = args.get("CodeContent")
                        if code_content:
                            file_contents[target_file] = code_content

print(f"Found {len(file_contents)} files in transcript to restore.")

for path, content in file_contents.items():
    print(f"Restoring: {path}")
    try:
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(content)
    except Exception as e:
        print(f"Failed to write {path}: {e}")

print("Done restoring files.")
