# MCP Proxy with Node.js support
# Extends mcp-proxy to include npx for running node-based MCP servers

FROM ghcr.io/sparfenyuk/mcp-proxy:latest

# Install Node.js (Alpine package) and n8n-mcp
RUN apk add --no-cache nodejs npm && \
    npm install -g n8n-mcp

# Ensure npx is available
ENV PATH="/usr/local/bin:$PATH"

# Default entrypoint from base image
ENTRYPOINT ["catatonit", "--", "mcp-proxy"]
