# SupportDesk RAG Workshop -- reproducible environment.
#
# Why a container at all? The host-install path for this workshop has a long
# tail of failure modes that have nothing to do with RAG: chromadb depends on
# Pydantic V1 internals that Python 3.13 removed, virtualenv activation differs
# across PowerShell/CMD/bash, and `python` vs `py` vs `python3` varies by OS.
# Pinning the interpreter and dependencies inside an image removes all of it.

FROM python:3.12-slim-bookworm

# build-essential covers any dependency that still ships an sdist rather than a
# wheel. curl is here so the container can smoke-test its own network access.
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential curl \
 && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    # Headless image: matplotlib must not try to open a window.
    MPLBACKEND=Agg \
    # Chroma phones home by default. Off, so the workshop makes no network
    # calls other than the ones the modules make deliberately.
    ANONYMIZED_TELEMETRY=False \
    CHROMA_TELEMETRY_ENABLED=False

WORKDIR /workspace

# Dependencies are installed as a separate layer from the source, so editing a
# module does not trigger a reinstall.
#
# We install from the lock file rather than requirements.txt: the loose bounds
# in requirements.txt resolved to a working set once, and the lock records
# exactly which one, so a rebuild months from now behaves identically.
COPY requirements.txt requirements.lock.txt /workspace/
RUN pip install -r /workspace/requirements.lock.txt

# Run as a non-root user whose ids match the host user, so files the modules
# write through the bind mount (PNGs, Chroma directories) stay editable on the
# host instead of coming back owned by root.
ARG APP_UID=1000
ARG APP_GID=1000
RUN if ! getent group "${APP_GID}" >/dev/null; then groupadd -g "${APP_GID}" app; fi \
 && if ! getent passwd "${APP_UID}" >/dev/null; then \
        useradd -u "${APP_UID}" -g "${APP_GID}" -m -s /bin/bash app; \
    fi \
 && chown -R "${APP_UID}:${APP_GID}" /workspace

USER ${APP_UID}:${APP_GID}

CMD ["bash"]
