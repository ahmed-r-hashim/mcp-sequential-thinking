# ---------- Builder ----------
FROM valkama.saunalahti.fi/image/python:3.14-alpine AS builder

WORKDIR /app

RUN apk add --no-cache build-base python3-dev \
    && pip install --no-cache-dir uv

# Build into an isolated venv so we can copy just that into runtime
RUN uv venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY pyproject.toml README.md ./
COPY mcp_sequential_thinking/ ./mcp_sequential_thinking

RUN uv pip install --no-cache --python /opt/venv/bin/python .

# ---------- Runtime ----------
FROM valkama.saunalahti.fi/image/python:3.14-alpine AS runtime

RUN addgroup -S app && adduser -S app -G app \
    && mkdir -p /data && chown -R app:app /data

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    MCP_STORAGE_DIR=/data \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER app
WORKDIR /app

EXPOSE 8485

CMD ["python", "-m", "mcp_sequential_thinking.server", "--port", "8485", "--transport", "sse", "--host", "0.0.0.0"]
