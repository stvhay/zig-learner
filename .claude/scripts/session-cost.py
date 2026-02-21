#!/usr/bin/env python3
"""
Claude Code Session Cost Analyzer

Analyzes a .jsonl session transcript and computes cost from the three
variables the agent controls: n (turn count), cᵢ (new context per turn),
and oᵢ (output per turn).

Cost formula (exact):

  cost = S·n·r + r·Σⱼ cⱼ·(n-j-1) + w·Σⱼ cⱼ + p·Σⱼ oⱼ
         ├─────┘   ├──────────────┘   ├───────┘   ├───────┘
         │         │                  │            └─ output cost
         │         │                  └─ cache write cost
         │         └─ context replay cost (cⱼ replayed by all later turns)
         └─ system context replayed every turn

Where:
  S   = fixed system context (system prompt + tool defs), from turn 0 cache_read
  cⱼ  = cache_creation_input_tokens at turn j (differential new context)
  oⱼ  = output tokens at turn j
  n   = number of API calls
  r   = cache read price per token
  w   = cache write price per token
  p   = output price per token

JSONL format notes:
  - Multiple lines share message.id (streaming chunks) with identical usage.
    Deduplicate by message.id.
  - output_tokens in usage undercounts ~50×. Estimated from content length.
  - usage.cache_creation nests {ephemeral_1h_input_tokens, ephemeral_5m_input_tokens}
    with different prices.
"""

import json
import sys
import argparse


PRICING = {
    "claude-opus-4-6": {
        "input": 5.00e-6, "cache_1h": 10.00e-6, "cache_5m": 6.25e-6,
        "cache_read": 0.50e-6, "output": 25.00e-6,
    },
    "claude-opus-4-5-20251101": {
        "input": 5.00e-6, "cache_1h": 10.00e-6, "cache_5m": 6.25e-6,
        "cache_read": 0.50e-6, "output": 25.00e-6,
    },
    "claude-sonnet-4-5-20250929": {
        "input": 3.00e-6, "cache_1h": 6.00e-6, "cache_5m": 3.75e-6,
        "cache_read": 0.30e-6, "output": 15.00e-6,
    },
    "claude-haiku-4-5-20251001": {
        "input": 1.00e-6, "cache_1h": 2.00e-6, "cache_5m": 1.25e-6,
        "cache_read": 0.10e-6, "output": 5.00e-6,
    },
}

CHARS_PER_TOKEN = 4


def get_prices(model: str) -> dict:
    if model in PRICING:
        return PRICING[model]
    for key in PRICING:
        if model.startswith(key.split("-20")[0]):
            return PRICING[key]
    return PRICING["claude-sonnet-4-5-20250929"]


def parse_session(filepath: str) -> list[dict]:
    seen = {}
    order = []

    with open(filepath) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            obj = json.loads(line)
            msg = obj.get("message", {})
            if not isinstance(msg, dict):
                continue

            msg_id = msg.get("id")
            usage = msg.get("usage")
            if not msg_id or not usage:
                continue

            if msg_id not in seen:
                cd = usage.get("cache_creation", {})
                if not isinstance(cd, dict):
                    cd = {}

                seen[msg_id] = {
                    "msg_id": msg_id,
                    "model": msg.get("model", "unknown"),
                    "timestamp": obj.get("timestamp"),
                    "cache_1h_write": cd.get("ephemeral_1h_input_tokens", 0),
                    "cache_5m_write": cd.get("ephemeral_5m_input_tokens", 0),
                    "cache_creation_total": usage.get("cache_creation_input_tokens", 0),
                    "cache_read": usage.get("cache_read_input_tokens", 0),
                    "output_tokens_reported": usage.get("output_tokens", 0),
                    "content_chars": 0,
                    "message_text": "",
                    "tool_calls": [],
                }
                order.append(msg_id)

            entry = seen[msg_id]
            for c in msg.get("content", []):
                ctype = c.get("type")
                if ctype == "text":
                    text = c.get("text", "")
                    entry["content_chars"] += len(text)
                    entry["message_text"] += text
                elif ctype == "tool_use":
                    tool_input = json.dumps(c.get("input", {}))
                    entry["content_chars"] += len(tool_input)
                    entry["tool_calls"].append(c.get("name", ""))

    return [seen[mid] for mid in order]


def analyze(filepath: str) -> dict:
    entries = parse_session(filepath)
    if not entries:
        return {"error": "No API call entries found", "filepath": filepath}

    model = entries[0]["model"]
    prices = get_prices(model)
    r = prices["cache_read"]
    p = prices["output"]

    n = len(entries)
    S = entries[0]["cache_read"]

    c_vec = [e["cache_creation_total"] for e in entries]
    o_vec = [max(e["output_tokens_reported"], e["content_chars"] // CHARS_PER_TOKEN) for e in entries]
    w_vec = [
        e["cache_1h_write"] * prices["cache_1h"] + e["cache_5m_write"] * prices["cache_5m"]
        for e in entries
    ]

    # ── Exact cost formula ──
    system_replay_cost = S * n * r
    context_replay_cost = sum(c_vec[j] * (n - j - 1) * r for j in range(n))
    cache_write_cost = sum(w_vec)
    output_cost = sum(o_vec) * p
    total_cost = system_replay_cost + context_replay_cost + cache_write_cost + output_cost

    # ── Per-call breakdown ──
    cumulative_context = 0
    cumulative_cost = 0.0
    per_call = []

    for i, e in enumerate(entries):
        replay_this_turn = (S + cumulative_context) * r
        write_this_turn = w_vec[i]
        output_this_turn = o_vec[i] * p
        future_replay_cost = c_vec[i] * (n - i - 1) * r
        call_cost = replay_this_turn + write_this_turn + output_this_turn
        cumulative_cost += call_cost
        cumulative_context += c_vec[i]

        message_summary = e["message_text"][:500]
        if len(e["message_text"]) > 500:
            message_summary += "..."

        per_call.append({
            "call_index": i,
            "msg_id": e["msg_id"],
            "timestamp": e["timestamp"],
            "c_i": c_vec[i],
            "o_i": o_vec[i],
            "cumulative_context": cumulative_context,
            "cost": {
                "replay": round(replay_this_turn, 6),
                "cache_write": round(write_this_turn, 6),
                "output": round(output_this_turn, 6),
                "total": round(call_cost, 6),
                "cumulative": round(cumulative_cost, 6),
                "future_replay": round(future_replay_cost, 6),
            },
            "message": {
                "text": message_summary,
                "tool_calls": e["tool_calls"],
            },
        })

    return {
        "filepath": str(filepath),
        "model": model,
        "n": n,
        "S": S,
        "formula": "S*n*r + r*Σ cⱼ*(n-j-1) + w*Σ cⱼ + p*Σ oⱼ",
        "cost": {
            "system_replay": round(system_replay_cost, 6),
            "context_replay": round(context_replay_cost, 6),
            "cache_write": round(cache_write_cost, 6),
            "output": round(output_cost, 6),
            "total": round(total_cost, 6),
        },
        "vectors": {
            "c": c_vec,
            "o": o_vec,
        },
        "prices": {
            "r": r, "w_1h": prices["cache_1h"],
            "w_5m": prices["cache_5m"], "p": p,
        },
        "per_call": per_call,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Analyze Claude Code session cost"
    )
    parser.add_argument("jsonl", help="Path to .jsonl session file")
    parser.add_argument("--summary", action="store_true",
                        help="Human-readable summary to stderr")
    parser.add_argument("--pretty", action="store_true",
                        help="Pretty-print JSON output")
    parser.add_argument("--compact", action="store_true",
                        help="Cost components and total only")

    args = parser.parse_args()
    result = analyze(args.jsonl)

    if "error" in result:
        json.dump(result, sys.stdout)
        print()
        sys.exit(1)

    if args.compact:
        c = result["cost"]
        json.dump({
            "n": result["n"],
            "S": result["S"],
            "system_replay": c["system_replay"],
            "context_replay": c["context_replay"],
            "cache_write": c["cache_write"],
            "output": c["output"],
            "total": c["total"],
        }, sys.stdout)
        print()
        return

    if args.summary:
        c = result["cost"]
        t = c["total"]
        pct = lambda v: v / t * 100 if t else 0
        print(f"Session: {result['filepath']}", file=sys.stderr)
        print(f"Model: {result['model']}, n={result['n']}, S={result['S']:,}", file=sys.stderr)
        print(f"Formula: {result['formula']}", file=sys.stderr)
        print(f"  System replay (S·n·r):      ${c['system_replay']:.4f}  ({pct(c['system_replay']):.1f}%)", file=sys.stderr)
        print(f"  Context replay (r·Σcⱼ·...): ${c['context_replay']:.4f}  ({pct(c['context_replay']):.1f}%)", file=sys.stderr)
        print(f"  Cache writes (w·Σcⱼ):       ${c['cache_write']:.4f}  ({pct(c['cache_write']):.1f}%)", file=sys.stderr)
        print(f"  Output (p·Σoⱼ):             ${c['output']:.4f}  ({pct(c['output']):.1f}%)", file=sys.stderr)
        print(f"  Total:                       ${t:.4f}", file=sys.stderr)
        print(file=sys.stderr)

    indent = 2 if args.pretty else None
    json.dump(result, sys.stdout, indent=indent, default=str)
    print()


if __name__ == "__main__":
    main()

