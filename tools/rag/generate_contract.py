"""Generate the checked-in RAG limit/watch contract from the canonical TOML."""

from __future__ import annotations

import json
from pathlib import Path

from state import CONTRACT_PATH, config_fingerprint, load_config


def generate() -> dict:
    config = load_config()
    indexing = config["indexing"]
    limits = config["limits"]
    return {
        "config_hash": config_fingerprint(config),
        "search": {"limit": limits["search_limit"]},
        "read": {"neighbors": limits["read_neighbors"], "content_chars": limits["read_content_chars"]},
        "context": {"limit": limits["context_limit"], "neighbors": limits["context_neighbors"], "content_chars": limits["context_content_chars"]},
        "eval": {"limit": limits["eval_limit"]},
        "indexing": {
            "allowed_extensions": indexing["allowed_extensions"],
            "default_target_dirs": indexing["default_target_dirs"],
        },
        "watch": config["watch"],
    }


def main() -> None:
    payload = generate()
    CONTRACT_PATH.write_text(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
