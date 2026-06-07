import sys

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "r", encoding="utf-8") as f:
    content = f.read().rstrip()

# Ensure it ends with the closing braces
if not content.endswith("}"):
    # If the last non-empty line doesn't end with a closing brace, let's make sure we close the match and the function.
    content += "\n    }\n}\n"

with open(r"c:\Users\tombl\Documents\lurek_2D\src\render\gpu_pipeline.rs", "w", encoding="utf-8") as f:
    f.write(content)

print("gpu_pipeline.rs braces fixed.")
