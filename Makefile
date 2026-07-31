# SupportDesk RAG Workshop
#
# Python runs from the repo-local .venv. The make targets use its interpreter
# directly, so activation is optional:
#
#   make setup    # one time: create .venv, install dependencies, create .env
#   make verify   # confirm the API key and models work
#   make m1       # run module 1 ... through make m6
#
# Each module runs from its own directory because the demos load the dataset
# with a relative path (../../data/synthetic_tickets.json).

SHELL := /bin/bash

PYTHON       ?= python3.12
VENV_DIR     := $(CURDIR)/.venv
VENV_PYTHON  := $(VENV_DIR)/bin/python
INSTALL_MARK := $(VENV_DIR)/.requirements-installed

export PYTHONDONTWRITEBYTECODE := 1
export MPLBACKEND := Agg
export ANONYMIZED_TELEMETRY := False
export CHROMA_TELEMETRY_ENABLED := False

MODULES := 1_embeddings 2_chunking 3_indexing 4_rag_pipeline 5_evaluation 6_agentic_rag

.DEFAULT_GOAL := help
.PHONY: help setup env venv install verify run \
        m1 m2 m3 m4 m5 m6 all clean

help: ## Show this help
	@echo "SupportDesk RAG Workshop"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Modules: m1 embeddings | m2 chunking | m3 indexing"
	@echo "         m4 rag_pipeline | m5 evaluation | m6 agentic_rag"

# --- setup ------------------------------------------------------------------

setup: env install ## One-time setup: create .env and a Python 3.12 .venv
	@echo ""
	@echo "Ready. Next: put your OpenAI key in .env, then run 'make verify'."

env: ## Create .env from the template if it does not exist
	@if [ -f .env ]; then \
	  echo ".env already exists -- leaving it alone."; \
	else \
	  cp .env.example .env; chmod 600 .env; \
	  echo "Created .env from .env.example. Add your OPENAI_API_KEY."; \
	fi

$(VENV_PYTHON):
	@command -v "$(PYTHON)" >/dev/null || { \
	  echo "Python 3.12 was not found as '$(PYTHON)'. Install it, or run make setup PYTHON=/path/to/python3.12."; \
	  exit 1; \
	}
	@"$(PYTHON)" -c 'import sys; raise SystemExit(0 if sys.version_info[:2] == (3, 12) else 1)' || { \
	  "$(PYTHON)" --version; \
	  echo "This workshop requires Python 3.12."; \
	  exit 1; \
	}
	"$(PYTHON)" -m venv "$(VENV_DIR)"

venv: $(VENV_PYTHON) ## Create the local Python 3.12 virtual environment

$(INSTALL_MARK): requirements.lock.txt $(VENV_PYTHON)
	"$(VENV_PYTHON)" -m pip install -r requirements.lock.txt
	@touch "$(INSTALL_MARK)"

install: $(INSTALL_MARK) ## Install the exact workshop dependencies in .venv

verify: env install ## Check dependencies, API key, chat model, tool calling, embeddings
	"$(VENV_PYTHON)" verify_setup.py

# --- modules ----------------------------------------------------------------

define run_module
	@echo ""
	@echo "=============================================================="
	@echo "  Module $(1)"
	@echo "=============================================================="
	@cd "modules/$(2)" && "$(VENV_PYTHON)" demo.py
endef

m1: env install ## Module 1 -- embeddings and similarity
	$(call run_module,1: Embeddings,1_embeddings)

m2: env install ## Module 2 -- chunking strategies
	$(call run_module,2: Chunking,2_chunking)

m3: env install ## Module 3 -- indexing strategies (LlamaIndex)
	$(call run_module,3: Indexing,3_indexing)

m4: env install ## Module 4 -- the RAG pipeline (LangChain LCEL)
	$(call run_module,4: RAG Pipeline,4_rag_pipeline)

m5: env install ## Module 5 -- retrieval and generation evaluation
	$(call run_module,5: Evaluation,5_evaluation)

m6: env install ## Module 6 -- agentic RAG with tool calling
	$(call run_module,6: Agentic RAG,6_agentic_rag)

run: env install ## Run any file: make run FILE=modules/1_embeddings/scratch.py
	@test -n "$(FILE)" || { \
	  echo "Usage: make run FILE=modules/1_embeddings/scratch.py"; exit 1; }
	@test -f "$(FILE)" || { echo "No such file: $(FILE)"; exit 1; }
	@cd "$(dir $(FILE))" && "$(VENV_PYTHON)" "$(notdir $(FILE))"

all: env install ## Run every module in order, unattended
	@for m in $(MODULES); do \
	  echo ""; echo "=============================================================="; \
	  echo "  $$m"; \
	  echo "=============================================================="; \
	  cd "$(CURDIR)/modules/$$m" && "$(VENV_PYTHON)" demo.py < /dev/null || exit 1; \
	done
	@echo ""; echo "All modules completed."

# --- cleanup ----------------------------------------------------------------

clean: ## Delete generated vector stores, caches and images (keep .venv)
	@rm -rf __pycache__ modules/*/chroma_db modules/*/rag_vectorstore* \
	        modules/*/agent_vectorstore modules/*/solution_chroma_db \
	        modules/*/__pycache__ modules/*/*.png
	@echo "Generated artifacts removed; .venv and .env were kept."
