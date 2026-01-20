@echo off
echo === MCP Docker Setup ===
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker ist nicht installiert!
    echo Bitte Docker Desktop installieren: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

REM Check if .env exists
if not exist .env (
    echo .env Datei nicht gefunden!
    echo Erstelle aus .env.example...
    copy .env.example .env
    echo.
    echo WICHTIG: Bitte oeffne .env und trage deine Credentials ein!
    echo Dann starte dieses Script erneut.
    pause
    exit /b 1
)

echo Starting MCP containers...
docker compose up -d

echo.
echo === Container Status ===
docker compose ps

echo.
echo Fertig! MCP Server laufen jetzt.
echo.
echo Endpoints:
echo   n8n-mcp:      http://localhost:3001
echo   github-mcp:   http://localhost:3003
echo   supabase-mcp: http://localhost:3002
echo   context7:     https://mcp.context7.com/mcp
echo.
pause
