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
            
        if data.get("type") == "PLANNER_RESPONSE":
            for call in data.get("tool_calls", []):
                name = call.get("name", "")
                if "write_to_file" in name:
                    args = call.get("args") or call.get("arguments") or {}
                    
                    target = args.get("TargetFile", "")
                    if target:
                        target = target.replace('"', '').replace('\\\\', '/').replace('\\', '/')
                        
                        if ".agents/rules" in target or ".agents/workflows" in target:
                            content = args.get("CodeContent", "")
                            if content:
                                if content.startswith('"') and content.endswith('"'):
                                    try:
                                        content = json.loads(content)
                                    except:
                                        pass
                                # Always take the last one in the file
                                file_contents[target] = content

print(f"Found {len(file_contents)} files to restore.")

for path, content in file_contents.items():
    print(f"Restoring: {path}")
    try:
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            f.write(content)
    except Exception as e:
        print(f"Failed to write {path}: {e}")

print("Done restoring files.")
