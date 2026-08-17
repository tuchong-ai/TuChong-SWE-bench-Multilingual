#!/usr/bin/env python3
"""
verify_dataset.py — Dataset integrity verification script

Usage:
    python tools/verify_dataset.py [bundle_dir]

When bundle_dir is not specified, defaults to the parent of the script's directory.

Checks:
  1. bundle.json internal consistency (instance_count / image_count / selected_instance_ids aligned)
  2. INDEX.jsonl entry count == bundle.json instance_count
  3. images/images.jsonl entry count == bundle.json image_count
  4. instances/ directory count == bundle.json instance_count
  5. Each instance directory contains 14 required files
  6. All .patch files are valid unified diffs
  7. Dockerfile FROM tags exist in images.jsonl
  8. FAIL_TO_PASS / PASS_TO_PASS do not contain :: double-colon format (must use # hash)
  9. INDEX.jsonl contains all required release audit fields
 10. All swe_bench_instance.version fields are non-empty
 11. CHECKSUMS.sha256 covers all files and verifies correctly
"""

import hashlib
import json
import os
import re
import sys
from pathlib import Path

REQUIRED_FILES = [
    "Dockerfile",
    "setup_repo.sh",
    "setup_env.sh",
    "run_tests.sh",
    "base_commit.txt",
    "gold_patch.patch",
    "test_patch.patch",
    "model_patch.patch",
    "UPSTREAM_LICENSE.txt",
    "task.jsonl",
    "environment.json",
    "model_input.json",
    "trajectory.canonical.jsonl",
    "trajectory.full.jsonl",
]

PATCH_HEADER_RE = re.compile(r"^diff --git ", re.MULTILINE)

# Repository infrastructure (not dataset payload), by path relative to the
# repository root, excluded from checksum coverage. Instance-level README.md
# files under instances/ remain covered.
EXCLUDE_DIRS = {"__pycache__", ".pytest_cache", ".mypy_cache", ".git", "node_modules", "assets"}
EXCLUDE_FILES = {"CHECKSUMS.sha256", "README.md", "LICENSE"}


def check(name: str, ok: bool, detail: str = "") -> bool:
    status = "PASS" if ok else "FAIL"
    msg = f"  [{status}] {name}"
    if detail:
        msg += f": {detail}"
    print(msg)
    return ok


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def safe_read_text(path: Path) -> str | None:
    """Read a file as text, returning None on encoding errors."""
    try:
        return path.read_text(encoding="utf-8")
    except (UnicodeDecodeError, OSError):
        return None


def safe_read_json(path: Path) -> dict | None:
    """Read and parse a JSON file, returning None on any error."""
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError):
        return None


def safe_read_jsonl(path: Path) -> list[dict] | None:
    """Read and parse a JSONL file, returning None on any error."""
    try:
        results = []
        with open(path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    results.append(json.loads(line))
        return results
    except (json.JSONDecodeError, OSError):
        return None


def verify_bundle(bundle_dir: Path) -> bool:
    all_ok = True
    print(f"\n=== Verifying: {bundle_dir} ===\n")

    # --- 1. bundle.json ---
    bundle_path = bundle_dir / "bundle.json"
    if not bundle_path.exists():
        return check("bundle.json exists", False, "file not found")

    bundle = safe_read_json(bundle_path)
    if bundle is None:
        return check("bundle.json: valid JSON", False, "parse error")

    declared_count = bundle.get("instance_count", 0)
    selected = bundle.get("selection_criteria", {}).get("selected_instance_ids", [])

    # D-1 fix: safely handle empty image_archives list
    img_archives = bundle.get("image_archives", [])
    if img_archives:
        declared_img_count = img_archives[0].get("image_count", 0)
    else:
        declared_img_count = 0
        all_ok &= check("bundle.json: image_archives non-empty", False, "image_archives is empty")
    languages = bundle.get("languages", [])

    all_ok &= check("bundle.json: instance_count == len(selected)",
                    declared_count == len(selected),
                    f"{declared_count} vs {len(selected)}")

    # --- 2. INDEX.jsonl ---
    index_path = bundle_dir / "INDEX.jsonl"
    index_entries = []
    if index_path.exists():
        index_entries = safe_read_jsonl(index_path)
        if index_entries is None:
            all_ok &= check("INDEX.jsonl: valid JSONL", False, "parse error")
            index_entries = []
        else:
            all_ok &= check("INDEX.jsonl: valid JSONL", True)
    index_count = len(index_entries)
    all_ok &= check("INDEX.jsonl count == bundle.instance_count",
                    index_count == declared_count,
                    f"{index_count} vs {declared_count}")

    # --- 3. images.jsonl ---
    images_path = bundle_dir / "images" / "images.jsonl"
    img_tags = set()
    image_count = 0
    if images_path.exists():
        img_entries = safe_read_jsonl(images_path)
        if img_entries is None:
            all_ok &= check("images.jsonl: valid JSONL", False, "parse error")
        else:
            for d in img_entries:
                img_tags.add(d.get("tag", ""))
                image_count += 1
    all_ok &= check("images.jsonl count == bundle.image_count",
                    image_count == declared_img_count,
                    f"{image_count} vs {declared_img_count}")

    # --- 4. instances/ directories ---
    instances_dir = bundle_dir / "instances"
    instance_dirs = sorted([d.name for d in instances_dir.iterdir() if d.is_dir()]) if instances_dir.exists() else []
    all_ok &= check("instances/ count == bundle.instance_count",
                    len(instance_dirs) == declared_count,
                    f"{len(instance_dirs)} vs {declared_count}")

    # --- 5. Required files per instance ---
    for iid in instance_dirs:
        idir = instances_dir / iid
        missing = [f for f in REQUIRED_FILES if not (idir / f).exists()]
        all_ok &= check(f"{iid}: all {len(REQUIRED_FILES)} required files present",
                        not missing, f"missing: {missing}" if missing else "")

    # --- 6. Patch files are valid diffs ---
    for iid in instance_dirs:
        for patch_name in ("gold_patch.patch", "test_patch.patch", "model_patch.patch"):
            ppath = instances_dir / iid / patch_name
            if ppath.exists():
                content = safe_read_text(ppath)
                if content is None:
                    all_ok &= check(f"{iid}/{patch_name}: valid unified diff", False, "encoding error")
                else:
                    is_diff = bool(PATCH_HEADER_RE.search(content)) or content.strip() == ""
                    all_ok &= check(f"{iid}/{patch_name}: valid unified diff", is_diff)

    # --- 7. Dockerfile FROM tag exists in images.jsonl ---
    for iid in instance_dirs:
        df_path = instances_dir / iid / "Dockerfile"
        if df_path.exists():
            for line in df_path.read_text().splitlines():
                if line.startswith("ARG SOURCE_IMAGE="):
                    tag = line.split("=", 1)[1].strip()
                    found = tag in img_tags
                    all_ok &= check(f"{iid}/Dockerfile: FROM tag in images.jsonl",
                                    found, f"tag={tag}" if not found else "")
                    break

    # --- 8. FAIL_TO_PASS / PASS_TO_PASS format ---
    for iid in instance_dirs:
        task_path = instances_dir / iid / "task.jsonl"
        if not task_path.exists():
            continue
        d = safe_read_json(task_path)
        if d is None:
            all_ok &= check(f"{iid}/task.jsonl: valid JSON", False, "parse error")
            continue
        sbi = d.get("swe_bench_instance", {})
        for key in ("FAIL_TO_PASS", "PASS_TO_PASS"):
            val = sbi.get(key, "")
            if isinstance(val, str):
                try:
                    ids = json.loads(val)
                except json.JSONDecodeError:
                    ids = []
            elif isinstance(val, list):
                ids = val
            else:
                continue
            bad = [t for t in ids if "::" in t]
            all_ok &= check(f"{iid}: {key} uses # format (no ::)",
                            not bad, f"{len(bad)} entries with ::" if bad else "")

    # --- 9. Release audit: INDEX.jsonl has required audit fields ---
    required_audit_fields = [
        "contamination_level", "contamination_factors",
        "verified_rubric_version", "verified_rubric_model",
        "verified_ps_severity", "verified_tv_severity",
        "grading_logs",
        "license_spdx", "source_eligibility",
        "base_commit", "repo", "version",
    ]
    for d in index_entries:
        iid = d.get("instance_id", "?")
        missing_audit = [f for f in required_audit_fields if f not in d]
        all_ok &= check(f"{iid}: INDEX.jsonl has all audit fields",
                        not missing_audit,
                        f"missing: {missing_audit}" if missing_audit else "")

    # --- 10. Release audit: version field non-empty in all instances ---
    for iid in instance_dirs:
        task_path = instances_dir / iid / "task.jsonl"
        if task_path.exists():
            d = safe_read_json(task_path)
            if d is None:
                continue
            sbi = d.get("swe_bench_instance", {})
            ver = sbi.get("version", "")
            all_ok &= check(f"{iid}: swe_bench_instance.version non-empty",
                            bool(ver), f"version='{ver}'" if not ver else "")

    # --- 11. CHECKSUMS ---
    checksums_path = bundle_dir / "CHECKSUMS.sha256"
    if checksums_path.exists():
        # D-7 fix: collect all files excluding __pycache__ and similar dirs
        all_files = set()
        for root, dirs, files in os.walk(bundle_dir):
            # Prune excluded directories in-place
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for fname in files:
                rel = os.path.relpath(os.path.join(root, fname), bundle_dir)
                if rel in EXCLUDE_FILES:
                    continue
                all_files.add(rel)

        # Read recorded checksums
        recorded = {}
        try:
            with open(checksums_path, encoding="utf-8") as f:
                for line in f:
                    parts = line.strip().split(maxsplit=1)
                    if len(parts) == 2:
                        recorded[parts[1]] = parts[0]
        except OSError:
            all_ok &= check("CHECKSUMS: readable", False, "I/O error")
            recorded = {}

        # Check coverage
        uncovered = all_files - set(recorded.keys())
        all_ok &= check("CHECKSUMS covers all files", not uncovered,
                        f"{len(uncovered)} uncovered" if uncovered else "")

        # Check for stale entries (recorded but file no longer exists)
        stale = set(recorded.keys()) - all_files
        all_ok &= check("CHECKSUMS has no stale entries", not stale,
                        f"{len(stale)} stale: {sorted(stale)[:3]}" if stale else "")

        # Verify all checksums
        sampled = 0
        mismatches = 0
        for rel_path, expected_hash in sorted(recorded.items()):
            full_path = bundle_dir / rel_path
            if not full_path.exists():
                mismatches += 1
                sampled += 1
                continue
            actual = sha256_file(full_path)
            if actual != expected_hash:
                mismatches += 1
            sampled += 1

        all_ok &= check(f"CHECKSUMS verification ({sampled} files)", mismatches == 0,
                        f"{mismatches} mismatches" if mismatches else "")

    # --- Summary ---
    print(f"\n{'='*40}")
    print(f"Result: {'ALL PASS' if all_ok else 'HAS FAILURES'}")
    print(f"  Instances: {len(instance_dirs)}")
    print(f"  Images:    {image_count}")
    print(f"  Languages: {languages}")
    print(f"{'='*40}")
    return all_ok


if __name__ == "__main__":
    if len(sys.argv) > 1:
        bundle = Path(sys.argv[1])
    else:
        bundle = Path(__file__).resolve().parent.parent

    ok = verify_bundle(bundle)
    sys.exit(0 if ok else 1)
