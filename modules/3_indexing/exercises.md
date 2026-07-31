# Indexing Strategies Exercises

> ✅ **Exercise style for this workshop:** keep each solution to a **small edit** (usually 3–15 lines) in existing files.


## How to run these exercises

The workshop commands use the repo-local Python 3.12 environment in `.venv`.
The `make` targets call that interpreter directly, so you do not need to
activate it before each command.

Run `make setup` once, then run all exercise commands from the repo root.

| What you want | Command |
|---|---|
| Run this module's demo | `make m3` |
| Run a file you wrote yourself | `make run FILE=modules/3_indexing/scratch.py` |
| Undo your edits to the demo | `git checkout modules/3_indexing/demo.py` |
| Activate `.venv` for your own Python commands | `source .venv/bin/activate` |

## Fast navigation during class

All exercises on this page modify **one file**:
`modules/3_indexing/demo.py`.

Do not scroll through the file looking for the right section. Open the file,
press **Ctrl+F** (Windows/Linux) or **Cmd+F** (macOS), and paste the exact search
text from the table below. Line numbers are intentionally avoided because they
change as soon as you complete an exercise.

| Exercise | Search for this exact text | Action |
|---|---|---|
| 1 | `query = "How do I fix authentication` | Replace one line |
| 2 | `vector_query_engine = vector_index` | Replace one line |
| 3 | `tree_query_engine = tree_index` | Replace one line |
| 4 | `# PART 5: Hybrid Retrieval` | Paste immediately **above** this heading |
| 5 | `# PART 5: Hybrid Retrieval` | Paste immediately **above** this heading |
| 6 | `# PART 2: Summary Index` | Paste immediately **above** this heading |
| 7 | `# PART 2: Summary Index` | Paste immediately **above** this heading |
| 8 | `vector_index = VectorStoreIndex.from_documents` and `keyword_index = KeywordTableIndex.from_documents` | Replace two lines |
| Bonus | `for node in vector_nodes + keyword_nodes:` | Replace one line |

> **Important:** The snippets below are small patches for the existing demo.
> Do not create a new file or paste a second copy of the imports, data loading,
> settings, or index construction unless an exercise explicitly says to add an
> import.

**When something breaks.** Reset with the `git checkout` above and re-run. You
cannot damage anything permanently.

---

## Exercise 1: Change the Query (Easy)

**Task**: Modify the demo to search for a different type of issue.

**Where to edit:** Open `modules/3_indexing/demo.py`, press Ctrl+F/Cmd+F, and
search for `query = "How do I fix authentication`.

**Find this line:**
```python
query = "How do I fix authentication issues after password reset?"
```

**Change it to**:
```python
query = "Database connection is timing out"
```

**Run it:**

```bash
make m3
```

**Observe:**
- How do the results differ between Vector, Summary, Tree, and Keyword indexes?
- Which index type gives the most relevant answer?

**Try these queries too**:
- `"Email notifications not being delivered"`
- `"Mobile app crashes on startup"`
- `"Payment processing fails for international cards"`

---

## Exercise 2: Adjust the Number of Results (Easy)

**Task**: Get more search results from the Vector Index.

**Where to edit:** In `modules/3_indexing/demo.py`, press Ctrl+F/Cmd+F and search
for `vector_query_engine = vector_index`.

**Find this line:**
```python
vector_query_engine = vector_index.as_query_engine(similarity_top_k=3)
```

**Change it to**:
```python
vector_query_engine = vector_index.as_query_engine(similarity_top_k=5)
```

**Run it:**

```bash
make m3
```

**Observe:** Does getting more source documents improve the answer quality?

---

## Exercise 3: Change the Tree Index Branch Factor (Easy)

**Task**: Modify how many branches the Tree Index explores.

**Where to edit:** In `modules/3_indexing/demo.py`, press Ctrl+F/Cmd+F and search
for `tree_query_engine = tree_index`.

**Find this line:**
```python
tree_query_engine = tree_index.as_query_engine(child_branch_factor=2)
```

**Try different values**:
```python
# Explore only 1 branch (more focused, might miss relevant info)
tree_query_engine = tree_index.as_query_engine(child_branch_factor=1)

# Explore 3 branches (broader search, slower)
tree_query_engine = tree_index.as_query_engine(child_branch_factor=3)
```

**Run it:**

```bash
make m3
```

**Observe:** 
- How does `child_branch_factor=1` affect the answer?
- Is `child_branch_factor=3` noticeably slower?

---

## Exercise 4: Test a Keyword-Specific Query (Easy)

**Task**: See how Keyword Index handles exact term matching.

**Where to edit:**

1. Open `modules/3_indexing/demo.py`.
2. Press Ctrl+F/Cmd+F and search for `# PART 5: Hybrid Retrieval`.
3. Place your cursor on the blank line immediately **above** that heading.
4. Paste this block there:

```python
# Test keyword-specific query
keyword_query = "TICK-001"
print(f"\nKeyword-specific query: '{keyword_query}'")
keyword_response = keyword_query_engine.query(keyword_query)
print(f"Result: {keyword_response.response}")
```

**Run it:**

```bash
make m3
```

**Observe:** Does the Keyword Index find the exact ticket ID?

---

## Exercise 5: Compare Index Types Side-by-Side (Medium)

**Task**: Run the same query through two index types and compare with minimal edits.

Both query engines already exist in the demo. Do not copy the imports or rebuild
the indexes.

**Where to edit:**

1. Open `modules/3_indexing/demo.py`.
2. Press Ctrl+F/Cmd+F and search for `# PART 5: Hybrid Retrieval`.
3. Place your cursor on the blank line immediately **above** that heading.
4. If you completed Exercise 4, put this new block below the Exercise 4 block,
   while keeping both blocks above the Part 5 heading.
5. Paste this block:

```python
# Exercise 5: compare the existing Vector and Keyword query engines
test_queries = ["authentication login problem", "TICK-005"]

for test_query in test_queries:
    print("\n" + "=" * 60)
    print(f"Comparison query: '{test_query}'")
    print("=" * 60)

    vector_result = vector_query_engine.query(test_query)
    print("\nVector Index:")
    print(f"  {str(vector_result)[:150]}...")

    keyword_result = keyword_query_engine.query(test_query)
    print("\nKeyword Index:")
    print(f"  {str(keyword_result)[:150]}...")
```

**Answer**: Which index works best for "TICK-005" (exact match) vs "authentication login problem" (semantic)?

**Run it:**

```bash
make m3
```

---

## Exercise 6: Save and Load an Index (Medium)

**Task**: Persist and reload index with a small patch.

This exercise requires one import edit and one pasted block.

### Edit 1 of 2: add the persistence imports

1. Open `modules/3_indexing/demo.py`.
2. Press Ctrl+F/Cmd+F and search for `from llama_index.core import (`.
3. Add `StorageContext` and `load_index_from_storage` anywhere inside that
   existing parenthesized import list:

```text
    StorageContext,
    load_index_from_storage,
```

### Edit 2 of 2: save, load, and test the existing Vector Index

1. Press Ctrl+F/Cmd+F and search for `# PART 2: Summary Index`.
2. Place your cursor on the blank line immediately **above** that heading.
3. Paste this block:

```python
# Exercise 6: save the Vector Index that Part 1 already built
vector_index.storage_context.persist(persist_dir="./my_saved_index")
print("✓ Saved to ./my_saved_index")

storage_context = StorageContext.from_defaults(persist_dir="./my_saved_index")
loaded_index = load_index_from_storage(storage_context)

saved_index_query = "login problem"
saved_index_response = loaded_index.as_query_engine().query(saved_index_query)
print(f"Reloaded index result: {saved_index_response}")
```

**Why this matters**: Building indexes is expensive (API calls). Persisting saves time and money!

**Run it:**

```bash
make m3
```

---

## Exercise 7: Add Metadata Filtering (Medium)

**Task**: Filter search results by category with one filter object.

This exercise requires one import edit and one pasted block.

### Edit 1 of 2: add the filter imports

1. Open `modules/3_indexing/demo.py`.
2. Press Ctrl+F/Cmd+F and search for `from llama_index.embeddings.openai`.
3. Add this new import on the line immediately **above** it:

```python
from llama_index.core.vector_stores import ExactMatchFilter, MetadataFilters
```

### Edit 2 of 2: compare unfiltered and filtered Vector searches

1. Press Ctrl+F/Cmd+F and search for `# PART 2: Summary Index`.
2. Place your cursor on the blank line immediately **above** that heading.
3. If you completed Exercise 6, put this block below the Exercise 6 block,
   while keeping both blocks above the Part 2 heading.
4. Paste this block:

```python
# Exercise 7: compare the existing Vector Index with and without a filter
filter_query = "system problem"
unfiltered_response = vector_index.as_query_engine(similarity_top_k=3).query(
    filter_query
)
print(f"Without filter: {unfiltered_response}")

filters = MetadataFilters(
    filters=[ExactMatchFilter(key="category", value="Authentication")]
)
filtered_engine = vector_index.as_query_engine(similarity_top_k=3, filters=filters)
filtered_response = filtered_engine.query(filter_query)
print(f"With Authentication filter: {filtered_response}")
```

**Try changing the filter**:
- `value="Database"`
- `value="Performance"`

**Run it:**

```bash
make m3
```

---

## Exercise 8: Benchmark Index Build Time (Medium)

**Task**: Measure build time with a tiny timing patch.

This exercise makes three small edits to the existing demo. Do not build a
second set of indexes.

### Edit 1 of 3: import `time`

1. Open `modules/3_indexing/demo.py`.
2. Press Ctrl+F/Cmd+F and search for `import os`.
3. Add `import time` on the next line.

### Edit 2 of 3: time the existing Vector Index build

Press Ctrl+F/Cmd+F and search for this exact line:

```python
vector_index = VectorStoreIndex.from_documents(documents)
```

Replace that one line with:

```python
vector_start = time.time()
vector_index = VectorStoreIndex.from_documents(documents)
vector_seconds = time.time() - vector_start
print(f"Vector Index build time: {vector_seconds:.2f}s")
```

### Edit 3 of 3: time the existing Keyword Index build

Press Ctrl+F/Cmd+F and search for this exact line:

```python
keyword_index = KeywordTableIndex.from_documents(keyword_documents)
```

Replace that one line with:

```python
keyword_start = time.time()
keyword_index = KeywordTableIndex.from_documents(keyword_documents)
keyword_seconds = time.time() - keyword_start
print(f"Keyword Index build time: {keyword_seconds:.2f}s")
```

**Run it:**

```bash
make m3
```

---

## Bonus Exercise: Simple Hybrid Search (Challenge)

**Task**: Combine Vector and Keyword search results.

The demo already contains the hybrid retrieval and deduplication logic. For this
challenge, limit the fusion step to the top two results from each retriever.

**Where to edit:**

1. Open `modules/3_indexing/demo.py`.
2. Press Ctrl+F/Cmd+F and search for this exact line:

```python
for node in vector_nodes + keyword_nodes:
```

3. Replace it with:

```python
for node in vector_nodes[:2] + keyword_nodes[:2]:
```

**Run it:**

```bash
make m3
```

---

## Quick Reference

### Index Types
```python
from llama_index.core import (
    VectorStoreIndex,
    SummaryIndex,
    TreeIndex,
    KeywordTableIndex,
)

# Vector: Semantic similarity search
vector_index = VectorStoreIndex.from_documents(documents)

# Summary: Reads all docs, good for high-level queries (slow for large datasets)
summary_index = SummaryIndex.from_documents(documents)

# Tree: Hierarchical traversal, good for large collections
tree_index = TreeIndex.from_documents(documents)

# Keyword: Exact term matching, no embeddings needed
keyword_index = KeywordTableIndex.from_documents(documents)
```

### Query Engines
```python
# Basic query
engine = index.as_query_engine()
response = engine.query("your question")

# With parameters
engine = index.as_query_engine(similarity_top_k=5)

# Tree Index with branch factor
engine = tree_index.as_query_engine(child_branch_factor=2)
```

### Persistence
```python
# Save
index.storage_context.persist(persist_dir="./storage")

# Load
from llama_index.core import StorageContext, load_index_from_storage

storage_context = StorageContext.from_defaults(persist_dir="./storage")
loaded_index = load_index_from_storage(storage_context)
```

---

## Next Steps

Ready for **Module 4: RAG Pipeline**? We'll combine indexing with LLM generation to build a complete question-answering system!

---

**Questions?** Ask the instructor or refer back to the demo code!
