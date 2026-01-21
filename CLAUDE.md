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
| `ui-ux-pro-max` | Design intelligence (50+ styles, 97 palettes, 57 fonts) | After frontend-design for concrete recommendations |

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

**Available Tools:**

| Tool | Purpose |
|------|---------|
| `frontend-design` Skill | Aesthetic direction, creative code generation |
| `ui-ux-pro-max` Skill | Structured design data (50+ styles, 97 palettes, 57 fonts) |
| magic-mcp (Port 3005) | 21st.dev component inspiration & logos |

**ui-ux-pro-max Usage:**
```bash
# Full design system
py -3.12 -X utf8 skills/ui-ux-pro-max/scripts/search.py "<keywords>" --design-system -p "Name"

# Domain searches
py -3.12 skills/ui-ux-pro-max/scripts/search.py "<query>" --domain style|color|typography|ux|landing|product

# Stack-specific guidelines
py -3.12 skills/ui-ux-pro-max/scripts/search.py "<query>" --stack react|html-tailwind|nextjs|vue
```

**21st.dev MCP Tools:**
- `mcp__magic__21st_magic_component_inspiration` - Browse implementations
- `mcp__magic__21st_magic_component_builder` - Generate components
- `mcp__magic__logo_search` - Find brand logos

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
├── environments/             # ENCRYPTED API KEYS (SOPS/age)
│   ├── shared/               # Common APIs for all projects
│   ├── craft-connect-buddy/  # CCB-specific keys
│   ├── cleanOS/              # CleanOS-specific keys
│   ├── websitenerstellung/   # DataForSEO credentials
│   ├── docker-mcp/           # MCP server configuration
│   └── .sops.yaml            # SOPS encryption config
├── skills/
│   ├── n8n-mcp-tools-expert/
│   ├── n8n-workflow-patterns/
│   ├── n8n-code-javascript/
│   ├── n8n-code-python/
│   ├── n8n-expression-syntax/
│   ├── n8n-node-configuration/
│   ├── n8n-validation-expert/
│   ├── frontend-design/
│   └── ui-ux-pro-max/        # 50+ styles, 97 palettes, 57 fonts
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

## API Keys & Secrets Management

All API keys are stored **encrypted** in the `environments/` folder using SOPS with age encryption.

### Available API Keys

| File | Contains |
|------|----------|
| `environments/shared/.env.enc` | OpenAI (2x), Gemini, Perplexity, Firecrawl, Brevo, GitHub, Claude OAuth, Context7, N8N, Supabase Access Token |
| `environments/craft-connect-buddy/.env.enc` | Supabase keys (CCB project), Service Role Key |
| `environments/cleanOS/.env.enc` | Supabase keys (CleanOS project), Service Role Key |
| `environments/websitenerstellung/.env.enc` | DataForSEO Login & Password |
| `environments/docker-mcp/.env.enc` | MCP server configuration (N8N, Supabase, Context7, GitHub) |

### Decrypting API Keys

**Prerequisites:**
- SOPS installed (`winget install Mozilla.SOPS` on Windows)
- Age key file at `~/.config/sops/age/keys.txt`

**Commands:**
```bash
# Set the key file (Git Bash / Linux)
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"

# Windows (PowerShell) - key location
# C:\Users\<username>\.config\sops\age\keys.txt

# Decrypt and view a file
sops -d --output-type dotenv environments/shared/.env.enc

# Decrypt specific project
sops -d --output-type dotenv environments/craft-connect-buddy/.env.enc
sops -d --output-type dotenv environments/websitenerstellung/.env.enc
```

### Adding New Keys

1. Decrypt the file: `sops -d --output-type dotenv environments/shared/.env.enc > temp.env`
2. Edit `temp.env` and add your keys
3. Re-encrypt: `sops --config /dev/null --age "age1hw3cw9gcw8q700fltsqdn9rhrvuzhrqyk42yly7snftgshzpkpsquftt5f" --encrypt --input-type dotenv --output-type json temp.env > environments/shared/.env.enc`
4. Delete temp file: `rm temp.env`

### Key Locations Quick Reference

| API | Location |
|-----|----------|
| OpenAI | `shared/.env.enc` → `OPENAI_API_KEY` |
| Gemini | `shared/.env.enc` → `GEMINI_API_KEY` |
| Perplexity | `shared/.env.enc` → `PERPLEXITY_API_KEY` |
| Firecrawl | `shared/.env.enc` → `FIRECRAWL_API_KEY` |
| Brevo | `shared/.env.enc` → `BREVO_API_KEY` |
| DataForSEO | `websitenerstellung/.env.enc` → `DATAFORSEO_LOGIN`, `DATAFORSEO_PASSWORD` |
| GitHub | `shared/.env.enc` → `GITHUB_TOKEN` |
| N8N | `shared/.env.enc` → `N8N_API_URL`, `N8N_API_KEY` |
| Supabase (CCB) | `craft-connect-buddy/.env.enc` |
| Supabase (CleanOS) | `cleanOS/.env.enc` |

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

---

## Using MCP Servers from Other Projects

This repository provides **centralized MCP infrastructure** that can be used by any project. Other projects (like `n8n-automations`) should use these Docker-hosted MCP servers instead of running their own.

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│              Your Project (e.g., n8n-automations)           │
│                        Claude Code                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│  mcp-proxy (Python bridge on your machine)                  │
│  Command: py -3.12 -m mcp_proxy http://localhost:PORT/sse   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│         ai-agent-tools Docker Containers                    │
│    (localhost:3001-3005 - centralized infrastructure)       │
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Ensure Docker Containers Are Running

From the `ai-agent-tools` directory:

```powershell
# Windows
cd c:\KI-Projekte\ai-agent-tools\docker
docker-compose up -d --build

# Verify containers are running
docker-compose ps
```

### Step 2: Configure Claude Code MCP Servers

Run these commands **once** to add MCP servers to Claude Code:

```bash
claude mcp add n8n-docker -- py -3.12 -m mcp_proxy http://localhost:3001/sse
claude mcp add supabase-docker -- py -3.12 -m mcp_proxy http://localhost:3002/sse
claude mcp add github-docker -- py -3.12 -m mcp_proxy http://localhost:3003/sse
claude mcp add context7-docker -- py -3.12 -m mcp_proxy http://localhost:3004/sse
claude mcp add magic-docker -- py -3.12 -m mcp_proxy http://localhost:3005/sse
```

**Alternative: Manual JSON configuration** in `~/.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "n8n-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3001/sse"]
    },
    "supabase-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3002/sse"]
    },
    "github-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3003/sse"]
    },
    "context7-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3004/sse"]
    },
    "magic-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3005/sse"]
    }
  }
}
```

### Step 3: Verify Connection

1. Restart Claude Code
2. Type `/mcp` to see all connected servers
3. You should see 5 Docker-based MCP servers listed
4. Test with `n8n_health_check` tool

### Projects Using This Infrastructure

| Project | Location | Status |
|---------|----------|--------|
| ai-agent-tools | `c:\KI-Projekte\ai-agent-tools\` | Source (this repo) |
| n8n-automations | `c:\KI-Projekte\n8n automations\n8n-automations\` | Consumer |

### Important Notes

- **Single source of truth**: Only run Docker containers from ai-agent-tools
- **Port conflicts**: Do NOT run duplicate docker-compose files from other projects
- **API keys**: All API keys are configured in `ai-agent-tools/docker/.env`
- **Skills**: Shared via symlink to `ai-agent-tools/skills/`
