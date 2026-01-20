# AI Agent Tools - Agent Instructions

This file provides instructions for AI agents (Claude Code, Antigravity, etc.) working with this repository.

## Repository Purpose

This repository provides a centralized infrastructure for MCP (Model Context Protocol) servers and Claude Code skills that can be used by any AI agent from any project.

## Quick Reference

### MCP Server Endpoints

| Server | Port | Endpoint | Purpose |
|--------|------|----------|---------|
| n8n-mcp | 3001 | http://localhost:3001/sse | n8n Workflow Automation |
| supabase-mcp | 3002 | http://localhost:3002/sse | Supabase Database Access |
| github-mcp | 3003 | http://localhost:3003/sse | GitHub Repository Access |
| context7-mcp | 3004 | http://localhost:3004/sse | Code Documentation |
| magic-mcp | 3005 | http://localhost:3005/sse | UI Components (21st.dev) |

### Available Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| `n8n-mcp-tools-expert` | MCP tool usage guidance | Before any workflow creation |
| `n8n-workflow-patterns` | Workflow architecture patterns | When designing workflows |
| `n8n-expression-syntax` | Expression syntax guide | When writing `={{ }}` expressions |
| `n8n-code-javascript` | JavaScript Code node guide | When writing Code nodes |
| `n8n-code-python` | Python Code node guide | When writing Python in Code nodes |
| `n8n-node-configuration` | Node configuration patterns | When configuring complex nodes |
| `n8n-validation-expert` | Validation error handling | When encountering validation errors |
| `frontend-design` | UI/Frontend design | When creating web components |

---

## Setup Instructions

### For New PC Setup

If you're setting up this infrastructure on a new PC, follow the instructions in:
- **Antigravity**: See `SETUP-ANTIGRAVITY.md`
- **Claude Code**: See `SETUP-CLAUDE-CODE.md`

### Prerequisites

1. **Docker Desktop** - Must be installed and running
2. **Python 3.12** - NOT 3.14 (experimental has issues with mcp-proxy)
3. **mcp-proxy** - Install via `py -3.12 -m pip install mcp-proxy`

### Starting Docker Infrastructure

```bash
cd docker
docker-compose up -d --build
```

### Verifying Setup

1. Check Docker containers: `docker-compose -f docker/docker-compose.yml ps`
2. Test endpoints: `curl http://localhost:3001/sse`
3. In Claude Code: Type `/mcp` to see all servers

---

## Agent Guidelines

### When Working with n8n Workflows

**ALWAYS call the appropriate skill BEFORE:**

| Action | Required Skill |
|--------|----------------|
| Creating/editing any workflow | `n8n-mcp-tools-expert` |
| Writing expressions `={{ }}` | `n8n-expression-syntax` |
| Designing workflow architecture | `n8n-workflow-patterns` |
| Interpreting validation errors | `n8n-validation-expert` |
| Configuring complex nodes | `n8n-node-configuration` |
| Writing JavaScript Code nodes | `n8n-code-javascript` |
| Writing Python Code nodes | `n8n-code-python` |

### Critical n8n Rules

1. **Two nodeType formats exist:**
   - Validation tools: `nodes-base.slack` (short prefix)
   - Workflow tools: `n8n-nodes-base.slack` (full prefix)

2. **Webhook data is nested:**
   - WRONG: `$json.email`
   - RIGHT: `$json.body.email`

3. **Code nodes return format:**
   ```javascript
   // Always return array of objects with json property
   return [{json: {field: value}}];
   ```

4. **Expression syntax:**
   - In node fields: `={{ $json.body.email }}`
   - In Code nodes: `$json.body.email` (no expression syntax!)

### When Working with UI Components

Use the `frontend-design` skill and the magic-mcp server (port 3005) for:
- Creating React components
- Searching for logos
- Getting UI inspiration from 21st.dev

---

## File Structure

```
ai-agent-tools/
├── docker/
│   ├── docker-compose.yml    # All 5 MCP servers
│   ├── mcp-node.Dockerfile   # Custom Docker image
│   ├── n8n-mcp-filter.js     # n8n MCP filter
│   ├── .env.example          # API key template
│   └── start.bat             # Windows quick-start
├── skills/
│   ├── n8n-mcp-tools-expert/
│   ├── n8n-workflow-patterns/
│   ├── n8n-code-javascript/
│   ├── n8n-code-python/
│   ├── n8n-expression-syntax/
│   ├── n8n-node-configuration/
│   ├── n8n-validation-expert/
│   └── frontend-design/
├── config/
│   ├── antigravity-mcp-config.json
│   └── claude-mcp-config.json
├── setup-windows.ps1         # Windows setup (Admin)
├── setup-linux.sh            # Linux/Mac setup
├── README.md                 # Main documentation
├── SETUP-ANTIGRAVITY.md      # Antigravity setup guide
├── SETUP-CLAUDE-CODE.md      # Claude Code setup guide
└── CLAUDE.md                 # This file
```

---

## Troubleshooting

### Docker containers not starting
```bash
docker-compose -f docker/docker-compose.yml logs
docker-compose -f docker/docker-compose.yml restart
```

### MCP connection issues
1. Verify Docker is running: `docker ps`
2. Check ports: `netstat -an | findstr :3001`
3. Test endpoint: `curl http://localhost:3001/sse`

### Python version issues
Use `py -3.12` instead of `python`. Python 3.14 has known issues with mcp-proxy.

### Skills not available (Claude Code)
1. Check symlink: `dir $env:USERPROFILE\.claude\skills`
2. Symlink should point to `ai-agent-tools/skills`
3. Recreate symlink if needed (requires Admin on Windows)

### API key errors
1. Check `docker/.env` has all required keys
2. Restart affected container: `docker-compose restart n8n-mcp`
