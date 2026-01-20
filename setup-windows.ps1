#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Setup script for AI Agent Tools - MCP Infrastructure & Skills

.DESCRIPTION
    This script:
    1. Installs mcp-proxy (Python bridge)
    2. Creates skills symlink for Claude Code
    3. Starts Docker containers
    4. Configures MCP servers

.NOTES
    Run as Administrator (required for symlink creation)
#>

param(
    [switch]$SkipDocker,
    [switch]$SkipSkills,
    [switch]$AntigravityOnly,
    [switch]$ClaudeCodeOnly
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AI Agent Tools - Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = $PWD.Path }

Write-Host "Repository: $ScriptDir" -ForegroundColor Gray

# Paths
$DockerDir = Join-Path $ScriptDir "docker"
$SkillsDir = Join-Path $ScriptDir "skills"
$ConfigDir = Join-Path $ScriptDir "config"
$ClaudeSkills = Join-Path $env:USERPROFILE ".claude\skills"
$AntigravityConfig = Join-Path $env:USERPROFILE ".gemini\antigravity\mcp_config.json"

# ========================================
# Step 1: Check Prerequisites
# ========================================
Write-Host ""
Write-Host "[1/5] Checking prerequisites..." -ForegroundColor Yellow

# Check Python 3.12
Write-Host "  - Python 3.12... " -NoNewline
try {
    $pythonVersion = & py -3.12 --version 2>&1
    if ($pythonVersion -match "Python 3\.12") {
        Write-Host "OK" -ForegroundColor Green
    } else {
        throw "Not found"
    }
} catch {
    Write-Host "NOT FOUND" -ForegroundColor Red
    Write-Host "    Install Python 3.12 from https://python.org" -ForegroundColor Red
    exit 1
}

# Check Docker
Write-Host "  - Docker... " -NoNewline
try {
    $null = & docker --version 2>&1
    Write-Host "OK" -ForegroundColor Green
} catch {
    Write-Host "NOT FOUND" -ForegroundColor Red
    Write-Host "    Install Docker Desktop from https://docker.com" -ForegroundColor Red
    exit 1
}

# ========================================
# Step 2: Install mcp-proxy
# ========================================
Write-Host ""
Write-Host "[2/5] Installing mcp-proxy..." -ForegroundColor Yellow

$mcpProxyInstalled = & py -3.12 -m pip show mcp-proxy 2>&1
if ($mcpProxyInstalled -match "Name: mcp-proxy") {
    Write-Host "  - mcp-proxy already installed" -ForegroundColor Green
} else {
    Write-Host "  - Installing mcp-proxy..." -ForegroundColor Gray
    & py -3.12 -m pip install mcp-proxy
    Write-Host "  - mcp-proxy installed" -ForegroundColor Green
}

# ========================================
# Step 3: Setup Skills Symlink (Claude Code)
# ========================================
if (-not $SkipSkills -and -not $AntigravityOnly) {
    Write-Host ""
    Write-Host "[3/5] Setting up Claude Code skills symlink..." -ForegroundColor Yellow

    # Ensure .claude directory exists
    $claudeDir = Split-Path $ClaudeSkills -Parent
    if (-not (Test-Path $claudeDir)) {
        New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
    }

    # Handle existing skills
    if (Test-Path $ClaudeSkills) {
        $item = Get-Item $ClaudeSkills -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $existingTarget = $item.Target
            if ($existingTarget -eq $SkillsDir) {
                Write-Host "  - Symlink already correct" -ForegroundColor Green
            } else {
                Remove-Item $ClaudeSkills -Force
                New-Item -ItemType SymbolicLink -Path $ClaudeSkills -Target $SkillsDir | Out-Null
                Write-Host "  - Symlink updated" -ForegroundColor Green
            }
        } else {
            $backupPath = "$ClaudeSkills.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $ClaudeSkills $backupPath
            New-Item -ItemType SymbolicLink -Path $ClaudeSkills -Target $SkillsDir | Out-Null
            Write-Host "  - Existing skills backed up, symlink created" -ForegroundColor Green
        }
    } else {
        New-Item -ItemType SymbolicLink -Path $ClaudeSkills -Target $SkillsDir | Out-Null
        Write-Host "  - Symlink created" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "[3/5] Skipping skills symlink" -ForegroundColor Yellow
}

# ========================================
# Step 4: Start Docker Containers
# ========================================
if (-not $SkipDocker) {
    Write-Host ""
    Write-Host "[4/5] Starting Docker containers..." -ForegroundColor Yellow

    $envFile = Join-Path $DockerDir ".env"
    $envExample = Join-Path $DockerDir ".env.example"

    if (-not (Test-Path $envFile)) {
        Copy-Item $envExample $envFile
        Write-Host "  - Created .env from template" -ForegroundColor Yellow
        Write-Host "  - IMPORTANT: Edit docker/.env with your API keys!" -ForegroundColor Red
        Write-Host ""
        Write-Host "    Required keys:" -ForegroundColor Yellow
        Write-Host "    - N8N_API_URL, N8N_API_KEY" -ForegroundColor Gray
        Write-Host "    - SUPABASE_ACCESS_TOKEN, SUPABASE_PROJECT_REF, etc." -ForegroundColor Gray
        Write-Host "    - CONTEXT7_API_KEY" -ForegroundColor Gray
        Write-Host "    - GITHUB_TOKEN" -ForegroundColor Gray
        Write-Host "    - TWENTYFIRST_API_KEY" -ForegroundColor Gray
        Write-Host ""
    }

    Push-Location $DockerDir
    try {
        & docker-compose up -d --build
        Write-Host "  - Docker containers started" -ForegroundColor Green
    } finally {
        Pop-Location
    }
} else {
    Write-Host ""
    Write-Host "[4/5] Skipping Docker" -ForegroundColor Yellow
}

# ========================================
# Step 5: Configure MCP Servers
# ========================================
Write-Host ""
Write-Host "[5/5] MCP Configuration..." -ForegroundColor Yellow

if (-not $ClaudeCodeOnly) {
    Write-Host ""
    Write-Host "  ANTIGRAVITY:" -ForegroundColor Cyan
    Write-Host "  Copy config/antigravity-mcp-config.json to:" -ForegroundColor Gray
    Write-Host "  $AntigravityConfig" -ForegroundColor White
}

if (-not $AntigravityOnly) {
    Write-Host ""
    Write-Host "  CLAUDE CODE:" -ForegroundColor Cyan
    Write-Host "  Run these commands to add MCP servers:" -ForegroundColor Gray
    Write-Host "  claude mcp add n8n-docker -- py -3.12 -m mcp_proxy http://localhost:3001/sse" -ForegroundColor White
    Write-Host "  claude mcp add supabase-docker -- py -3.12 -m mcp_proxy http://localhost:3002/sse" -ForegroundColor White
    Write-Host "  claude mcp add github-docker -- py -3.12 -m mcp_proxy http://localhost:3003/sse" -ForegroundColor White
    Write-Host "  claude mcp add context7-docker -- py -3.12 -m mcp_proxy http://localhost:3004/sse" -ForegroundColor White
    Write-Host "  claude mcp add magic-docker -- py -3.12 -m mcp_proxy http://localhost:3005/sse" -ForegroundColor White
}

# ========================================
# Done
# ========================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "MCP Endpoints:" -ForegroundColor Yellow
Write-Host "  n8n-mcp:      http://localhost:3001/sse" -ForegroundColor Gray
Write-Host "  supabase-mcp: http://localhost:3002/sse" -ForegroundColor Gray
Write-Host "  github-mcp:   http://localhost:3003/sse" -ForegroundColor Gray
Write-Host "  context7-mcp: http://localhost:3004/sse" -ForegroundColor Gray
Write-Host "  magic-mcp:    http://localhost:3005/sse" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Edit docker/.env with your API keys" -ForegroundColor Gray
Write-Host "2. Restart your AI agent (Antigravity/Claude Code)" -ForegroundColor Gray
Write-Host "3. Test MCP tools" -ForegroundColor Gray
