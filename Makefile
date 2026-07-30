# SupportDesk RAG Workshop
#
# Everything runs inside the container. You need Docker and nothing else --
# no Python install, no virtualenv, no PATH surgery.
#
#   make setup    # one time: create .env, build the image, start the container
#   make verify   # confirm the API key and model work
#   make m1       # run module 1 ... through make m6
#
# Each module runs from its own directory because the demos load the dataset
# with a relative path (../../data/synthetic_tickets.json).

SHELL := /bin/bash

# Passed to the build so container-written files are owned by you, not root.
export APP_UID := $(shell id -u)
export APP_GID := $(shell id -g)

COMPOSE := docker compose
SVC     := workshop
EXEC    := $(COMPOSE) exec $(SVC)
# -T drops the TTY: needed when output is piped or redirected.
EXEC_T  := $(COMPOSE) exec -T $(SVC)

MODULES := 1_embeddings 2_chunking 3_indexing 4_rag_pipeline 5_evaluation 6_agentic_rag

.DEFAULT_GOAL := help
.PHONY: help setup env build up down restart shell verify \
        m1 m2 m3 m4 m5 m6 all clean nuke

help: ## Show this help
	@echo "SupportDesk RAG Workshop"
	@echo ""
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Modules: m1 embeddings | m2 chunking | m3 indexing"
	@echo "         m4 rag_pipeline | m5 evaluation | m6 agentic_rag"

# --- setup ------------------------------------------------------------------

setup: env build up ## One-time setup: .env, build image, start container
	@echo ""
	@echo "Ready. Next: put your OpenAI key in .env, then run 'make verify'."

env: ## Create .env from the template if it does not exist
	@if [ -f .env ]; then \
	  echo ".env already exists -- leaving it alone."; \
	else \
	  cp .env.example .env; chmod 600 .env; \
	  echo "Created .env from .env.example. Add your OPENAI_API_KEY."; \
	fi

build: ## Build the image
	$(COMPOSE) build

up: ## Start the container in the background
	@test -f .env || { echo "No .env found. Run 'make env' first."; exit 1; }
	$(COMPOSE) up -d

down: ## Stop and remove the container
	$(COMPOSE) down

restart: down up ## Restart the container

shell: ## Open a shell inside the container
	$(EXEC) bash

verify: ## Check the API key, the configured models, and key imports
	$(EXEC_T) python verify_setup.py

# --- modules ----------------------------------------------------------------

define run_module
	@echo ""
	@echo "=============================================================="
	@echo "  Module $(1)"
	@echo "=============================================================="
	$(EXEC) bash -c 'cd /workspace/modules/$(2) && python demo.py'
endef

m1: ## Module 1 -- embeddings and similarity
	$(call run_module,1: Embeddings,1_embeddings)

m2: ## Module 2 -- chunking strategies
	$(call run_module,2: Chunking,2_chunking)

m3: ## Module 3 -- indexing strategies (LlamaIndex)
	$(call run_module,3: Indexing,3_indexing)

m4: ## Module 4 -- the RAG pipeline (LangChain LCEL)
	$(call run_module,4: RAG Pipeline,4_rag_pipeline)

m5: ## Module 5 -- retrieval and generation evaluation
	$(call run_module,5: Evaluation,5_evaluation)

m6: ## Module 6 -- agentic RAG with tool calling
	$(call run_module,6: Agentic RAG,6_agentic_rag)

all: ## Run every module in order, unattended
	@for m in $(MODULES); do \
	  echo ""; echo "=============================================================="; \
	  echo "  $$m"; \
	  echo "=============================================================="; \
	  $(EXEC_T) bash -c "cd /workspace/modules/$$m && python demo.py < /dev/null" || exit 1; \
	done
	@echo ""; echo "All modules completed."

# --- cleanup ----------------------------------------------------------------

clean: ## Delete generated vector stores, caches and images
	@rm -rf modules/*/chroma_db modules/*/rag_vectorstore* modules/*/agent_vectorstore \
	        modules/*/solution_chroma_db modules/*/__pycache__ modules/*/*.png
	@echo "Generated artifacts removed."

nuke: down clean ## Stop the container and remove the built image
	-docker image rm supportdesk-rag-workshop:local
	@echo "Image removed. 'make setup' rebuilds from scratch."
