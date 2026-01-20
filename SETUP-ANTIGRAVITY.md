# Antigravity Setup

Anleitung zur Einrichtung der MCP-Server für Antigravity.

## Agent-Prompt (Kopieren & Einfügen)

Kopiere diesen Prompt an Antigravity auf einem neuen PC:

```
Ich richte diesen PC neu ein für AI-Agent-Tools.

1. Klone das Repository: git clone https://github.com/badalyan-max/ai-agent-tools
2. Wechsle ins Verzeichnis: cd ai-agent-tools
3. Lies die Datei SETUP-ANTIGRAVITY.md
4. Führe folgende Schritte aus:
   a) Kopiere docker/.env.example nach docker/.env
   b) Ich werde die API-Keys in .env eintragen
   c) Starte Docker: docker-compose -f docker/docker-compose.yml up -d --build
   d) Installiere mcp-proxy: py -3.12 -m pip install mcp-proxy
   e) Kopiere den Inhalt von config/antigravity-mcp-config.json in meine Antigravity Config:
      C:\Users\[USER]\.gemini\antigravity\mcp_config.json

Melde dich, wenn ich Antigravity neu starten soll.
```

---

## Manuelle Einrichtung

### Voraussetzungen

- Git installiert
- Docker Desktop installiert und gestartet
- Python 3.12 installiert (NICHT 3.14!)
- Node.js LTS installiert

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
```

### Schritt 3: Docker starten

```powershell
docker-compose up -d --build
# Warte 2-3 Minuten bis alle Container "healthy" sind
docker-compose ps
```

### Schritt 4: mcp-proxy installieren

```powershell
py -3.12 -m pip install mcp-proxy
```

### Schritt 5: Antigravity konfigurieren

Öffne die Datei:
```
C:\Users\DEIN_USER\.gemini\antigravity\mcp_config.json
```

Ersetze den Inhalt mit:
```json
{
  "mcpServers": {
    "n8n-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3001/sse"],
      "disabled": false
    },
    "supabase-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3002/sse"],
      "disabled": false
    },
    "github-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3003/sse"],
      "disabled": false
    },
    "context7-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3004/sse"],
      "disabled": false
    },
    "magic-docker": {
      "command": "py",
      "args": ["-3.12", "-m", "mcp_proxy", "http://localhost:3005/sse"],
      "disabled": false
    }
  }
}
```

Oder kopiere einfach `config/antigravity-mcp-config.json` in die Datei.

### Schritt 6: Antigravity neu starten

Schließe Antigravity komplett und öffne es erneut.

### Schritt 7: Testen

Frage den Agent: "Liste alle n8n workflows auf"

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

### "Command python not found"
Installiere Python 3.12 und stelle sicher, dass "Add to PATH" aktiviert ist.

### "mcp_proxy module not found"
```powershell
py -3.12 -m pip install mcp-proxy
```

### Tools werden nicht gefunden
1. Prüfe ob Docker läuft: `docker ps`
2. Prüfe ob alle Container laufen: `docker-compose ps`
3. Starte Antigravity komplett neu (Prozess killen)

### GitHub "Bad credentials"
Dein GitHub Token in `.env` ist falsch/abgelaufen. Erstelle einen neuen PAT auf GitHub.
