FROM valkama.saunalahti.fi/image/python:3.14-alpine

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    python3-dev \
    curl \
    && pip install --no-cache-dir uv

# Copy project files
COPY pyproject.toml ./
COPY README.md ./
COPY mcp_sequential_thinking/ ./mcp_sequential_thinking

# Install dependencies using uv (only main group by default)
RUN uv pip install --system poetry && \
    uv pip install --system .

# Expose the FastAPI port
EXPOSE 8485
# Default to SSE mode
CMD ["python", "-m","mcp_sequential_thinking.server", "--port", "8485", "--transport", "sse", "--host", "0.0.0.0"] 