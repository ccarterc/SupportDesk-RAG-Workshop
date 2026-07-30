# SupportDesk-RAG: A Support Ticket Retrieval & Troubleshooting Assistant

## Hands-On RAG Workshop with OpenAI

### Workshop Overview
This workshop teaches you to build a production-ready Retrieval-Augmented Generation (RAG) system using OpenAI embeddings and language models. By the end, you'll have a working assistant that answers incident queries using retrieved ticket context, with strong safeguards against hallucinations.

### Learning Objectives
- ✅ Generate and work with OpenAI embeddings
- ✅ Master chunking strategies for optimal retrieval
- ✅ Compare 5 different indexing strategies (LlamaIndex)
- ✅ Implement a complete RAG pipeline with LangChain
- ✅ Evaluate with two-layer metrics (retrieval + generation)
- ✅ Deploy anti-hallucination safeguards
- ✅ Build agentic RAG systems with multi-step reasoning

---

## 🚀 Quick Start

The workshop runs in Docker. You need **Docker Desktop** (Windows/macOS) or **Docker Engine + Compose** (Linux), and nothing else — no Python install, no virtualenv, no PATH changes.

```bash
git clone https://github.com/ccarterc/SupportDesk-RAG-Workshop.git
cd SupportDesk-RAG-Workshop

make setup          # creates .env, builds the image, starts the container
#  -> now edit .env and paste in your OpenAI API key
make verify         # confirms the key, the models, and every dependency
make m1             # run module 1
```

`make verify` should end with `Environment is ready.` If it doesn't, it tells you exactly which check failed.

### Why Docker?

Everything in this workshop is Python, and Python environments are where workshops go to die. The container pins the interpreter to 3.12 (which `chromadb` requires — it depends on Pydantic V1 internals that Python 3.13 removed), pins every dependency to a verified version in `requirements.lock.txt`, and behaves identically on Windows, macOS and Linux. No activation scripts, no execution policies, no `python` vs `py` vs `python3`.

### Getting your API key

1. Sign in at <https://platform.openai.com/api-keys> and create a key.
2. Open `.env` and set `OPENAI_API_KEY=sk-...`.
3. Run `make verify`.

`.env` is gitignored. Do not commit it.

---

## 🧰 Commands

Run `make help` to see these at any time.

| Command | What it does |
|---|---|
| `make setup` | One-time: create `.env`, build the image, start the container |
| `make verify` | Check dependencies, API key, chat model, tool calling, embeddings |
| `make m1` … `make m6` | Run one module |
| `make all` | Run all six modules back to back, unattended |
| `make shell` | Open a bash shell inside the container |
| `make clean` | Delete generated vector stores, caches and images |
| `make down` / `make restart` | Stop / restart the container |
| `make nuke` | Stop everything and delete the built image |

The repo is bind-mounted into the container, so **edit a file on your machine and re-run — no rebuild needed.** That's the point: the exercises expect you to change code and see what happens.

Rebuild only when dependencies change:

```bash
make build && make restart
```

---

## Workshop Modules

### Module 1: Embeddings (`modules/1_embeddings/`)
**Learn:**
- Generate embeddings using OpenAI API
- Compute semantic similarity scores
- Visualize similarity relationships with heatmaps

**Run:** `make m1`

---

### Module 2: Chunking (`modules/2_chunking/`)
**Learn:**
- Fixed-size vs recursive vs semantic chunking
- Structure-aware splitting (Markdown/HTML)
- Build vector stores with Chroma

**Run:** `make m2`

---

### Module 3: Indexing Strategies (`modules/3_indexing/`)
**Learn:**
- Vector Index — Semantic similarity search (most common)
- Summary Index — High-level document summaries
- Tree Index — Hierarchical retrieval patterns
- Keyword Table Index — Traditional keyword matching
- Hybrid Retrieval — Combining multiple strategies

**Technologies:** LlamaIndex for clean indexing abstractions

**Run:** `make m3`

---

### Module 4: RAG Pipeline (`modules/4_rag_pipeline/`)
**Learn:**
- Complete RAG architecture
- LangChain integration
- Prompt engineering for grounded responses
- Anti-hallucination strategies

**Run:** `make m4`

Module 4 ends with an interactive prompt — type questions, or `quit` to exit. Under `make all` it skips that section automatically.

---

### Module 5: Evaluation (`modules/5_evaluation/`)
**Learn:**
- Two-layer evaluation approach (Retrieval + Generation)
- Retrieval metrics (Precision@K, Recall@K, F1)
- Generation metrics (Groundedness, Completeness)
- LLM-as-judge for generation evaluation
- Creating comprehensive evaluation reports

**Technologies:** FAISS, LLM-as-Judge evaluation

**Run:** `make m5`

---

### Module 6: Agentic RAG (`modules/6_agentic_rag/`)
**Learn:**
- Creating custom tools for LangChain agents
- Building agents with OpenAI function calling
- Implementing conversation memory
- Multi-step reasoning with tool selection
- Comparing agentic vs direct RAG approaches

**Technologies:** LangChain Agents, OpenAI Function Calling

**Run:** `make m6`

---

## ⚙️ Configuration

`.env` holds your key and your model choices:

```env
# Required
OPENAI_API_KEY=sk-your-key-here

# Optional (defaults shown)
OPENAI_EMBEDDING_MODEL=text-embedding-3-small
OPENAI_CHAT_MODEL=gpt-5.6-luna
```

### Model options

**Chat:**
- `gpt-5.6-luna` (default) — current fast frontier model
- `gpt-5.4-mini` — cheaper, still recent
- `gpt-5.6-sol` — most capable, slower and pricier

**Embeddings:**
- `text-embedding-3-small` (1536 dims, recommended)
- `text-embedding-3-large` (3072 dims, highest quality)

### A note on `temperature`

Older RAG tutorials — including earlier versions of this workshop — set `temperature=0` to make answers deterministic. **The GPT-5 series removed that control**; the API rejects any value but the default. The modules therefore pass `reasoning_effort="none"` instead, which keeps calls fast and, on `/v1/chat/completions`, is also what allows function tools to work (module 6 depends on this).

The practical lesson is worth keeping: grounding comes from tight retrieval and a strict prompt, not from a sampling parameter. If you point `OPENAI_CHAT_MODEL` at an older model, `temperature=0` works again — but you shouldn't need it.

---

## 💰 Cost Estimate

Running all six modules: **well under $1**. Module 3 (which builds tree and keyword indexes) and module 5 (LLM-as-judge) make the most calls.

See [OpenAI Pricing](https://openai.com/api/pricing/) for current rates.

---

## 📁 Repository Structure

```
SupportDesk-RAG-Workshop/
├── README.md
├── Makefile                    # every command you need
├── Dockerfile                  # pinned Python 3.12 environment
├── compose.yaml
├── verify_setup.py             # pre-flight check
├── requirements.txt            # direct dependencies
├── requirements.lock.txt       # exact verified versions (used by the build)
├── .env.example                # copy to .env, add your key
├── POST_CLASS_GUIDE.md
├── data/
│   └── synthetic_tickets.json
└── modules/
    ├── 1_embeddings/           # demo.py, notes.md, exercises.md, solutions.py
    ├── 2_chunking/
    ├── 3_indexing/
    ├── 4_rag_pipeline/
    ├── 5_evaluation/
    └── 6_agentic_rag/          # + tools.py
```

Each module has the same four files: `demo.py` (what we walk through together), `notes.md` (the written version), `exercises.md` (your turn), and `solutions.py`.

---

## 🎯 Prerequisites

- Docker Desktop or Docker Engine + Compose
- An OpenAI API key
- Basic Python reading ability
- `make` — preinstalled on macOS/Linux; on Windows use WSL2, or run the `docker compose` commands from the Makefile directly

---

## 🛠️ Troubleshooting

### `make verify` fails on the API key
The key is missing, still the placeholder, or invalid. Check `.env`, then confirm the key is active and funded at <https://platform.openai.com/usage>.

### `docker: command not found` / `Cannot connect to the Docker daemon`
Docker isn't installed or isn't running. Start Docker Desktop and retry.

### `No .env found`
Run `make env` to create it from the template, then paste in your key.

### Rate limits (HTTP 429)
Wait 60 seconds and re-run. Module 3 makes the most calls in a burst.

### A module fails after you edited it
The bind mount means your edit is live. Revert with `git checkout modules/<module>/demo.py`.

### Changed `requirements.txt` and now imports fail
Rebuild: `make build && make restart`. To re-pin afterwards:
```bash
docker compose exec -T workshop pip freeze --all \
  | grep -vE '^(pip|setuptools|wheel)==' | sort > requirements.lock.txt
```

### Running without Docker
Supported but not recommended. You need **Python 3.12 exactly** (not 3.13/3.14 — `chromadb` breaks):
```bash
python3.12 -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.lock.txt
cp .env.example .env               # then add your key
cd modules/1_embeddings && python demo.py
```
Demos load data with a relative path, so run each one **from its own module directory**.

---

## 📚 Additional Resources

- [LangChain Documentation](https://python.langchain.com/)
- [LlamaIndex Documentation](https://docs.llamaindex.ai/)
- [FAISS Documentation](https://github.com/facebookresearch/faiss)
- [OpenAI API Reference](https://platform.openai.com/docs)
- [Chroma Documentation](https://docs.trychroma.com/)

---

## 📄 License

MIT License - Feel free to use for learning and teaching!
