# Claude Code Setup

Anleitung zur Einrichtung der MCP-Server und Skills für Claude Code.

## Agent-Prompt (Kopieren & Einfügen)

Kopiere diesen Prompt an Claude Code auf einem neuen PC:

```
Ich richte Claude Code auf diesem neuen PC ein für AI-Agent-Tools.

1. Klone das Repository: git clone https://github.com/badalyan-max/ai-agent-tools
2. Wechsle ins Verzeichnis: cd ai-agent-tools
3. Lies die Datei SETUP-CLAUDE-CODE.md
4. Führe das Setup-Script aus (als Administrator):
   - Windows: .\setup-windows.ps1
   - Linux/Mac: ./setup-linux.sh
5. Falls das Script nicht funktioniert, manuell:
   a) Erstelle Symlink für Skills (als Admin):
      Windows: New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills" -Target "REPO_PATH\skills"
      Linux: ln -sf "$(pwd)/skills" ~/.claude/skills
   b) Kopiere docker/.env.example nach docker/.env
   c) Ich werde die API-Keys in .env eintragen
   d) Starte Docker: docker-compose -f docker/docker-compose.yml up -d --build
   e) Installiere mcp-proxy: py -3.12 -m pip install mcp-proxy
   f) Füge MCP-Server zu Claude Code hinzu:
      claude mcp add n8n-docker -- py -3.12 -m mcp_proxy http://localhost:3001/sse
      claude mcp add supabase-docker -- py -3.12 -m mcp_proxy http://localhost:3002/sse
      claude mcp add github-docker -- py -3.12 -m mcp_proxy http://localhost:3003/sse
      claude mcp add context7-docker -- py -3.12 -m mcp_proxy http://localhost:3004/sse
      claude mcp add magic-docker -- py -3.12 -m mcp_proxy http://localhost:3005/sse

Starte Claude Code neu nach dem Setup.
```

---

## Manuelle Einrichtung

### Voraussetzungen

- Git installiert
- Docker Desktop installiert und gestartet
- Python 3.12 installiert (NICHT 3.14!)
- Claude Code CLI installiert
- **Admin-Rechte** (für Symlink auf Windows)

### Schritt 1: Repository klonen

```powershell
cd c:\Projekte
git clone https://github.com/badalyan-max/ai-agent-tools
cd ai-agent-tools
```

### Schritt 2: API-Keys konfigurieren

```powershell
cd docker
Copy-Item .env.example .env
notepad .env  # API-Keys eintragen
cd ..
```

### Schritt 3: Docker starten

```powershell
docker-compose -f docker/docker-compose.yml up -d --build
# Warte 2-3 Minuten
docker-compose -f docker/docker-compose.yml ps
```

### Schritt 4: mcp-proxy installieren

```powershell
py -3.12 -m pip install mcp-proxy
```

### Schritt 5: Skills Symlink erstellen

**Windows (PowerShell als Admin!):**
```powershell
# Backup falls vorhanden
if (Test-Path "$env:USERPROFILE\.claude\skills") {
    Rename-Item "$env:USERPROFILE\.claude\skills" "$env:USERPROFILE\.claude\skills.backup"
}

# Symlink erstellen
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills" -Target "c:\Projekte\ai-agent-tools\skills"
```

**Linux/Mac:**
```bash
# Backup und Symlink
mv ~/.claude/skills ~/.claude/skills.backup 2>/dev/null
ln -sf "$(pwd)/skills" ~/.claude/skills
```

### Schritt 6: MCP-Server zu Claude Code hinzufügen

**Option A: CLI Commands (Empfohlen)**
```bash
claude mcp add n8n-docker -- py -3.12 -m mcp_proxy http://localhost:3001/sse
claude mcp add supabase-docker -- py -3.12 -m mcp_proxy http://localhost:3002/sse
claude mcp add github-docker -- py -3.12 -m mcp_proxy http://localhost:3003/sse
claude mcp add context7-docker -- py -3.12 -m mcp_proxy http://localhost:3004/sse
claude mcp add magic-docker -- py -3.12 -m mcp_proxy http://localhost:3005/sse
```

**Option B: Manuell in Settings**

Füge zu `~/.claude/settings.local.json` hinzu:
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

### Schritt 7: Claude Code neu starten

### Schritt 8: Testen

- `/mcp` eingeben → 5 Server sollten erscheinen
- Skill testen: Rufe `n8n-mcp-tools-expert` auf

---

## Skills Übersicht

| Skill | Zweck | Wann verwenden |
|-------|-------|----------------|
| `n8n-mcp-tools-expert` | MCP-Tool Verwendung | Vor Workflow-Erstellung |
| `n8n-workflow-patterns` | Workflow-Architektur | Beim Design |
| `n8n-expression-syntax` | Expression-Syntax | Bei `={{ }}` Ausdrücken |
| `n8n-code-javascript` | JavaScript Code Nodes | Bei Code-Nodes |
| `n8n-code-python` | Python Code Nodes | Bei Python in Code-Nodes |
| `n8n-node-configuration` | Node-Konfiguration | Bei komplexen Nodes |
| `n8n-validation-expert` | Validierungsfehler | Bei Fehlern |
| `frontend-design` | UI/Frontend Design | Bei Web-Komponenten |

---

## MCP-Server Übersicht

| Server | Port | Endpunkt | Zweck |
|--------|------|----------|-------|
| n8n-mcp | 3001 | http://localhost:3001/sse | Workflow Automation |
| supabase-mcp | 3002 | http://localhost:3002/sse | Database Access |
| github-mcp | 3003 | http://localhost:3003/sse | Repository Access |
| context7-mcp | 3004 | http://localhost:3004/sse | Code Documentation |
| magic-mcp | 3005 | http://localhost:3005/sse | UI Components |

---

## Troubleshooting

### Symlink-Erstellung fehlgeschlagen (Windows)
PowerShell muss als Administrator ausgeführt werden.

### Python Version Fehler
Verwende `py -3.12` statt `python`. Python 3.14 hat bekannte Probleme.

### MCP-Server nicht sichtbar
1. Prüfe Docker: `docker ps`
2. Prüfe Ports: `netstat -an | findstr :3001`
3. Starte Claude Code neu

### Skills nicht verfügbar
1. Prüfe Symlink: `dir $env:USERPROFILE\.claude\skills`
2. Symlink muss auf `ai-agent-tools/skills` zeigen
