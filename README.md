# AI Agent Tools

Zentrale Infrastruktur für AI-Agenten (Antigravity, Claude Code, etc.) mit Docker-MCP-Servern und Claude Code Skills.

## Quick Start

```bash
# 1. Repository klonen
git clone https://github.com/badalyan-max/ai-agent-tools
cd ai-agent-tools

# 2. API-Keys konfigurieren
cp docker/.env.example docker/.env
# Editiere docker/.env mit deinen API-Keys

# 3. Setup ausführen
# Windows (PowerShell als Admin):
.\setup-windows.ps1

# Linux/Mac:
./setup-linux.sh
```

## Was ist enthalten?

### MCP-Server (Docker)

| Server | Port | Zweck |
|--------|------|-------|
| n8n-mcp | 3001 | Workflow Automation |
| supabase-mcp | 3002 | Database Access |
| github-mcp | 3003 | Repository Access |
| context7-mcp | 3004 | Code Documentation |
| magic-mcp | 3005 | UI Components (21st.dev) |

### Claude Code Skills

| Skill | Zweck |
|-------|-------|
| `n8n-mcp-tools-expert` | MCP-Tool Verwendung |
| `n8n-workflow-patterns` | Workflow-Architektur |
| `n8n-expression-syntax` | Expression-Syntax |
| `n8n-code-javascript` | JavaScript Code Nodes |
| `n8n-code-python` | Python Code Nodes |
| `n8n-node-configuration` | Node-Konfiguration |
| `n8n-validation-expert` | Validierungsfehler |
| `frontend-design` | UI/Frontend Design |

## Repository-Struktur

```
ai-agent-tools/
├── docker/                       # MCP-Server Infrastruktur
│   ├── docker-compose.yml        # Alle 5 MCP-Server
│   ├── mcp-node.Dockerfile       # Custom Docker-Image
│   ├── .env.example              # API-Key Template
│   └── ...
├── skills/                       # Claude Code Skills
│   ├── n8n-mcp-tools-expert/
│   ├── n8n-workflow-patterns/
│   └── ...
├── config/                       # Fertige Konfigurationen
│   ├── antigravity-mcp-config.json
│   └── claude-mcp-config.json
├── setup-windows.ps1             # Windows Setup
├── setup-linux.sh                # Linux/Mac Setup
├── SETUP-ANTIGRAVITY.md          # Antigravity Anleitung
├── SETUP-CLAUDE-CODE.md          # Claude Code Anleitung
└── CLAUDE.md                     # Agent Instructions
```

## Detaillierte Anleitungen

- **Antigravity:** Siehe [SETUP-ANTIGRAVITY.md](SETUP-ANTIGRAVITY.md)
- **Claude Code:** Siehe [SETUP-CLAUDE-CODE.md](SETUP-CLAUDE-CODE.md)

## Voraussetzungen

- **Docker Desktop** - [docker.com](https://docker.com)
- **Python 3.12** - [python.org](https://python.org) (NICHT 3.14!)
- **Git** - [git-scm.com](https://git-scm.com)
- **Node.js LTS** - [nodejs.org](https://nodejs.org) (für npx)

## API-Keys

Die folgenden API-Keys werden benötigt (in `docker/.env`):

| Key | Beschreibung | Wo bekommst du ihn? |
|-----|--------------|---------------------|
| `N8N_API_URL` | URL deiner n8n-Instanz | Dein n8n Server |
| `N8N_API_KEY` | n8n API Key | n8n Settings → API |
| `SUPABASE_ACCESS_TOKEN` | Supabase PAT | [supabase.com/dashboard/account/tokens](https://supabase.com/dashboard/account/tokens) |
| `SUPABASE_PROJECT_REF` | Supabase Projekt-ID | Supabase Dashboard |
| `CONTEXT7_API_KEY` | Context7 Key | [context7.com](https://context7.com) |
| `GITHUB_TOKEN` | GitHub PAT | [github.com/settings/tokens](https://github.com/settings/tokens) |
| `TWENTYFIRST_API_KEY` | 21st.dev Key | [21st.dev](https://21st.dev) |

## Verwendung von anderen Projekten

Nach dem Setup laufen die MCP-Server auf `localhost:3001-3005`. Du kannst sie von **jedem** Projekt aus nutzen - die Konfiguration muss nur einmal pro PC eingerichtet werden.

## Troubleshooting

### Python Version Fehler
Verwende `py -3.12` statt `python`. Python 3.14 (experimental) hat bekannte Probleme mit mcp-proxy.

### Docker Container starten nicht
```bash
cd docker
docker-compose logs  # Logs anzeigen
docker-compose down && docker-compose up -d --build  # Neustart
```

### Symlink-Fehler (Windows)
PowerShell muss als Administrator ausgeführt werden für Symlinks.

### MCP-Server nicht erreichbar
1. Prüfe ob Docker läuft: `docker ps`
2. Prüfe ob Ports frei sind: `netstat -an | findstr :3001`
3. Prüfe Container-Logs: `docker-compose logs n8n-mcp`
