"""
Pre-flight check for the workshop environment.

Run this once after `make setup` and again before you present. It answers the
four questions that actually break a live demo:

  1. Are the dependencies importable at the versions we expect?
  2. Is an API key present?
  3. Does the configured chat model answer -- with the parameters this
     workshop uses?
  4. Does the configured embedding model answer, and at what dimension?

Usage:  make verify        (or: python verify_setup.py)
"""

import os
import sys

from dotenv import load_dotenv

load_dotenv()

CHAT_MODEL = os.getenv("OPENAI_CHAT_MODEL", "gpt-5.6-luna")
EMBED_MODEL = os.getenv("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")

ok = True


def report(passed: bool, label: str, detail: str = "") -> None:
    global ok
    if not passed:
        ok = False
    mark = "PASS" if passed else "FAIL"
    print(f"  [{mark}] {label}" + (f" -- {detail}" if detail else ""))


print("=" * 70)
print("SupportDesk RAG Workshop -- environment check")
print("=" * 70)

# --- 1. Interpreter and dependencies -----------------------------------------
print("\n1. Interpreter and dependencies")

major, minor = sys.version_info[:2]
report(
    (major, minor) == (3, 12),
    f"Python {major}.{minor}",
    "" if (major, minor) == (3, 12) else "workshop targets 3.12 (chromadb needs it)",
)

for label, module in [
    ("openai", "openai"),
    ("langchain", "langchain"),
    ("langchain-openai", "langchain_openai"),
    ("llama-index", "llama_index.core"),
    ("chromadb", "chromadb"),
    ("faiss", "faiss"),
    ("numpy", "numpy"),
    ("matplotlib", "matplotlib"),
]:
    try:
        mod = __import__(module, fromlist=["__version__"])
        report(True, label, getattr(mod, "__version__", "imported"))
    except Exception as exc:  # noqa: BLE001 -- we want the reason, whatever it is
        report(False, label, f"{type(exc).__name__}: {exc}")

# --- 2. API key ---------------------------------------------------------------
print("\n2. API key")

api_key = os.getenv("OPENAI_API_KEY", "")
if not api_key:
    report(
        False, "OPENAI_API_KEY", "not set -- copy .env.example to .env and add your key"
    )
elif api_key.startswith("sk-your-key") or "your_openai_api_key" in api_key:
    report(False, "OPENAI_API_KEY", "still the placeholder from .env.example")
else:
    # Show only enough to tell two keys apart. Never print the whole thing.
    report(True, "OPENAI_API_KEY", f"present ({api_key[:7]}...{api_key[-4:]})")

# --- 3 and 4. Live API calls --------------------------------------------------
if not ok:
    print("\nSkipping live API checks -- fix the failures above first.")
    sys.exit(1)

from openai import OpenAI

client = OpenAI(api_key=api_key, timeout=30.0)

print(f"\n3. Chat model: {CHAT_MODEL}")
try:
    resp = client.chat.completions.create(
        model=CHAT_MODEL,
        messages=[{"role": "user", "content": "Reply with the single word: ready"}],
        # The two parameters the GPT-5 series changed. Verifying them here means
        # a mismatch surfaces now rather than mid-demo.
        reasoning_effort="none",
        max_completion_tokens=16,
    )
    report(True, "chat completion", repr(resp.choices[0].message.content.strip()))
except Exception as exc:  # noqa: BLE001
    report(False, "chat completion", f"{type(exc).__name__}: {str(exc)[:200]}")

print("\n   Tool calling (module 6 depends on this)")
try:
    resp = client.chat.completions.create(
        model=CHAT_MODEL,
        messages=[{"role": "user", "content": "Find tickets about login failures."}],
        tools=[
            {
                "type": "function",
                "function": {
                    "name": "search_tickets",
                    "description": "Search past support tickets",
                    "parameters": {
                        "type": "object",
                        "properties": {"query": {"type": "string"}},
                        "required": ["query"],
                    },
                },
            }
        ],
        reasoning_effort="none",
    )
    calls = resp.choices[0].message.tool_calls
    report(
        bool(calls),
        "function tools",
        calls[0].function.name if calls else "model did not call the tool",
    )
except Exception as exc:  # noqa: BLE001
    report(False, "function tools", f"{type(exc).__name__}: {str(exc)[:200]}")

print(f"\n4. Embedding model: {EMBED_MODEL}")
try:
    emb = client.embeddings.create(
        model=EMBED_MODEL, input="login failure after password reset"
    )
    vec = emb.data[0].embedding
    report(True, "embedding", f"{len(vec)} dimensions")
except Exception as exc:  # noqa: BLE001
    report(False, "embedding", f"{type(exc).__name__}: {str(exc)[:200]}")

print("\n" + "=" * 70)
if ok:
    print("Environment is ready. Run 'make m1' to start.")
else:
    print("Environment is NOT ready. See the failures above.")
print("=" * 70)

sys.exit(0 if ok else 1)
