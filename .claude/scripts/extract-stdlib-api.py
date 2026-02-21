#!/usr/bin/env python3
"""
Extract Zig stdlib API surface (pub fn signatures + doc comments) for RAG indexing.

Reads from the Zig stdlib in the Nix store (path from `zig env`),
writes per-module API files to references/stdlib/.

Usage:
    python3 extract-stdlib-api.py [--output-dir DIR]

Default output: .claude/skills/zig-expert/references/stdlib/
"""

import json
import os
import subprocess
import sys
import argparse


# Modules to extract, grouped by relevance
MODULES = [
    # Top-level (high-frequency)
    "array_list.zig",
    "hash_map.zig",
    "mem.zig",
    "fmt.zig",
    "sort.zig",
    "json.zig",
    "atomic.zig",
    "time.zig",
    "net.zig",
    "fs.zig",
    "heap.zig",
    "io.zig",
    "testing.zig",
    "Thread.zig",
    "posix.zig",
    "process.zig",
    # Subdirectories (targeted)
    "Thread/Pool.zig",
    "Thread/Mutex.zig",
    "Thread/Condition.zig",
    "Thread/WaitGroup.zig",
    "Thread/Semaphore.zig",
    "Thread/RwLock.zig",
    "fs/Dir.zig",
    "fs/File.zig",
    "fs/path.zig",
    "heap/arena_allocator.zig",
    "compress/flate.zig",
    "crypto/Sha1.zig",
]


def get_std_dir() -> str:
    result = subprocess.run(
        ["zig", "env"], capture_output=True, text=True, check=True
    )
    # zig env outputs a Zig struct literal, not JSON — parse std_dir manually
    for line in result.stdout.splitlines():
        line = line.strip().rstrip(",")
        if line.startswith(".std_dir"):
            # .std_dir = "/path/to/std"
            return line.split("=", 1)[1].strip().strip('"')
    raise RuntimeError("Could not find std_dir in `zig env` output")


def extract_api(filepath: str, module_name: str) -> str:
    """Extract pub fn signatures, pub type declarations, and /// doc comments."""
    with open(filepath) as f:
        lines = f.readlines()

    output = [f"// Zig 0.15.2 std.{module_name} — API signatures + doc comments", ""]
    doc_buffer: list[str] = []
    skip_test = False
    brace_depth = 0

    for line in lines:
        stripped = line.strip()

        # Skip test blocks
        if stripped.startswith("test ") and '"' in stripped:
            skip_test = True
            brace_depth = 0
            continue
        if skip_test:
            brace_depth += stripped.count("{") - stripped.count("}")
            if brace_depth <= 0:
                skip_test = False
            continue

        # Collect doc comments
        if stripped.startswith("///"):
            doc_buffer.append(line.rstrip())
            continue

        # Public function declarations
        is_pub_fn = stripped.startswith("pub fn ") or stripped.startswith(
            "pub inline fn "
        )

        # Public type declarations (struct, enum, union, opaque)
        is_pub_type = stripped.startswith("pub const ") and any(
            f"= {kw}" in stripped
            for kw in ("struct", "enum", "union", "opaque")
        )

        # Public const fn types
        is_pub_fn_type = stripped.startswith("pub const ") and "= fn(" in stripped

        if is_pub_fn or is_pub_type or is_pub_fn_type:
            if doc_buffer:
                output.extend(doc_buffer)
                doc_buffer = []

            if is_pub_fn:
                sig = stripped
                if "{" in sig:
                    sig = sig[: sig.index("{")].rstrip()
                output.append(sig)
            else:
                output.append(stripped)
            output.append("")
        else:
            doc_buffer = []

    return "\n".join(output)


def main():
    parser = argparse.ArgumentParser(description="Extract Zig stdlib API for RAG")
    parser.add_argument(
        "--output-dir",
        default=os.path.join(
            os.path.dirname(__file__),
            "..",
            "skills",
            "zig-expert",
            "references",
            "stdlib",
        ),
    )
    args = parser.parse_args()

    std_dir = get_std_dir()
    out_dir = os.path.realpath(args.output_dir)
    os.makedirs(out_dir, exist_ok=True)

    print(f"Zig std: {std_dir}")
    print(f"Output:  {out_dir}")
    print()

    total_orig = 0
    total_extracted = 0
    extracted_count = 0

    for module in MODULES:
        src = os.path.join(std_dir, module)
        if not os.path.isfile(src):
            print(f"  SKIP {module} (not found)")
            continue

        orig_size = os.path.getsize(src)
        # Module name for the header comment (e.g., "Thread.Pool" from "Thread/Pool.zig")
        mod_name = module.replace("/", ".").removesuffix(".zig")
        extracted = extract_api(src, mod_name)
        ext_size = len(extracted)

        # Write to flat file (Thread/Pool.zig -> Thread_Pool.md)
        out_name = module.replace("/", "_").removesuffix(".zig") + ".md"
        out_path = os.path.join(out_dir, out_name)
        with open(out_path, "w") as f:
            f.write(extracted)

        total_orig += orig_size
        total_extracted += ext_size
        extracted_count += 1
        ratio = ext_size / orig_size * 100 if orig_size else 0
        print(f"  {module:35s}  {orig_size:>8,} -> {ext_size:>6,}  ({ratio:.0f}%)")

    print()
    print(
        f"Extracted {extracted_count} modules: "
        f"{total_orig:,} -> {total_extracted:,} bytes "
        f"({total_extracted / total_orig * 100:.0f}%)"
    )


if __name__ == "__main__":
    main()
