#!/usr/bin/env python3
"""Audit docstring quality - identifies files with poor/unclear module documentation."""

import json
import re
from pathlib import Path

MIN_QUALITY_LENGTH = 120  # Reasonable docstring should have at least this per line
MIN_LINES = 3  # Minimum sensible docstring lines

# Files and folders to skip
SKIP_FOLDERS = {"lua_api", "tests"}

# Quality indicators - if docstring has NONE of these, it's likely low-quality
QUALITY_INDICATORS = {
    "functionality": r"\b(provide|implement|define|manage|handle|compute|store|track|coordinate|execute|process|transform|render|generate|analyze|validate|serialize|deserialize)\b",
    "purpose": r"\b(use|using|for|purpose|goal|intend|design|contract|interface|API)\b",
    "input_output": r"\b(input|output|return|accept|receive|emit|send|produce|consume|yield)\b",
    "integration": r"\b(integration|interface|boundary|layer|module|component|subsystem|system)\b",
}

def collect_file_docstring(file_path):
    """Extract file-level //! docstring from the beginning of the file."""
    lines = []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                stripped = line.strip()
                if stripped.startswith("//!"):
                    content = stripped[3:].strip()
                    lines.append(content)
                elif stripped.startswith("//"):
                    continue
                elif not stripped or stripped.startswith("use ") or stripped.startswith("mod ") or stripped.startswith("pub "):
                    if lines:
                        break
                else:
                    if lines:
                        break
    except:
        return []
    return lines

def assess_quality(docstring_lines):
    """
    Assess docstring quality (0-100).

    Returns: (score, issues)
    - score: 0-100, where <50 is poor quality
    - issues: list of quality problems found
    """
    if not docstring_lines:
        return 0, ["No docstring found"]

    issues = []
    combined_text = " ".join(docstring_lines).lower()

    # Check line count
    if len(docstring_lines) < 2:
        issues.append(f"Only {len(docstring_lines)} line(s) - too brief")

    # Check character depth per line
    short_lines = [line for line in docstring_lines if len(line) < MIN_QUALITY_LENGTH]
    if short_lines:
        issues.append(f"{len(short_lines)} line(s) under {MIN_QUALITY_LENGTH} chars: incomplete thoughts")

    # Check for quality indicators
    found_indicators = set()
    for category, pattern in QUALITY_INDICATORS.items():
        if re.search(pattern, combined_text):
            found_indicators.add(category)

    if not found_indicators:
        issues.append("Missing quality indicators (functionality, purpose, input/output, integration)")
    elif len(found_indicators) == 1:
        issues.append(f"Only 1 quality indicator ({list(found_indicators)[0]}) - lacks depth")

    # Check for generic/worthless phrases that indicate placeholder text
    bad_phrases = [
        "with comprehensive implementation",
        "within the lurek2d",
        "game development",
        "module implementation",
        "core functionality",
        "contains",  # too vague
        "various",  # too vague
        "includes",  # too vague
    ]

    has_bad_phrases = [p for p in bad_phrases if p in combined_text]
    if has_bad_phrases:
        issues.append(f"Contains filler phrases: {', '.join(has_bad_phrases[:2])}")

    # Check if text is actually explaining something
    if combined_text.count(" ") < 15:  # Less than 15 words total
        issues.append("Too few words to constitute meaningful explanation")

    # Calculate score
    score = 100
    score -= len(issues) * 15
    score = max(0, score)

    return score, issues

def main():
    repo_root = Path(__file__).parent.parent.parent
    src_dir = repo_root / "src"

    results = {
        "good": [],
        "mediocre": [],
        "poor": [],
    }

    total_files = 0

    # Scan all .rs files
    for rs_file in sorted(src_dir.rglob("*.rs")):
        # Skip lua_api and tests
        if any(part in rs_file.parts for part in SKIP_FOLDERS):
            continue

        total_files += 1
        rel_path = rs_file.relative_to(repo_root)

        docstring = collect_file_docstring(rs_file)
        score, issues = assess_quality(docstring)

        entry = {
            "file": str(rel_path),
            "score": score,
            "issues": issues,
            "docstring_lines": docstring[:3] if docstring else [],
        }

        if score >= 70:
            results["good"].append(entry)
        elif score >= 40:
            results["mediocre"].append(entry)
        else:
            results["poor"].append(entry)

    # Save JSON report
    report_file = repo_root / "logs" / "data" / "docstring_quality_audit.json"
    report_file.parent.mkdir(parents=True, exist_ok=True)

    with open(report_file, "w") as f:
        json.dump({
            "total_files_scanned": total_files,
            "good_quality": len(results["good"]),
            "mediocre_quality": len(results["mediocre"]),
            "poor_quality": len(results["poor"]),
            "results": results,
        }, f, indent=2)

    # Generate markdown report for poor quality files
    md_file = repo_root / "DOCSTRING_QUALITY_REPORT.md"

    with open(md_file, "w") as f:
        f.write("# Docstring Quality Report\n\n")
        f.write(f"**Summary**: {len(results['poor'])} files require quality improvements\n\n")

        if results["poor"]:
            f.write("## Files Requiring Docstring Improvements\n\n")
            f.write("These files have weak, unclear, or placeholder docstrings that need rewriting with high-quality, explanatory documentation.\n\n")

            for i, entry in enumerate(results["poor"], 1):
                f.write(f"### {i}. [{entry['file']}]({entry['file']})\n\n")
                f.write(f"**Quality Score**: {entry['score']}/100\n\n")
                f.write(f"**Issues**:\n")
                for issue in entry["issues"]:
                    f.write(f"- {issue}\n")
                f.write(f"\n**Current Docstring**:\n```\n")
                for line in entry["docstring_lines"]:
                    f.write(f"{line}\n")
                f.write(f"```\n\n")

        if results["mediocre"]:
            f.write(f"## Files with Mediocre Quality ({len(results['mediocre'])})\n\n")
            f.write("These could be improved but are somewhat acceptable.\n\n")
            for entry in results["mediocre"][:10]:  # Show first 10
                f.write(f"- [{entry['file']}]({entry['file']}) - Score: {entry['score']}/100\n")
            if len(results["mediocre"]) > 10:
                f.write(f"- ... and {len(results['mediocre']) - 10} more\n")

    print(f"\n=== Docstring Quality Audit ===")
    print(f"Total files scanned: {total_files}")
    print(f"Good quality: {len(results['good'])}")
    print(f"Mediocre: {len(results['mediocre'])}")
    print(f"Poor quality requiring fixes: {len(results['poor'])}")
    print(f"\nReports generated:")
    print(f"  - {report_file}")
    print(f"  - {md_file}")

if __name__ == "__main__":
    main()
