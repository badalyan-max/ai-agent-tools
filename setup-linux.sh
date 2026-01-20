#!/bin/bash
#
# AI Agent Tools - Setup Script for Linux/Mac
#
# This script:
# 1. Installs mcp-proxy (Python bridge)
# 2. Creates skills symlink for Claude Code
# 3. Starts Docker containers
# 4. Shows MCP configuration instructions
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

# Parse arguments
SKIP_DOCKER=false
SKIP_SKILLS=false
ANTIGRAVITY_ONLY=false
CLAUDE_CODE_ONLY=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --skip-docker) SKIP_DOCKER=true ;;
        --skip-skills) SKIP_SKILLS=true ;;
        --antigravity-only) ANTIGRAVITY_ONLY=true ;;
        --claude-code-only) CLAUDE_CODE_ONLY=true ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo "  --skip-docker       Skip starting Docker containers"
            echo "  --skip-skills       Skip skills symlink creation"
            echo "  --antigravity-only  Configure for Antigravity only"
            echo "  --claude-code-only  Configure for Claude Code only"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

echo -e "${CYAN}========================================"
echo "AI Agent Tools - Setup"
echo -e "========================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "${GRAY}Repository: $SCRIPT_DIR${NC}"

# Paths
DOCKER_DIR="$SCRIPT_DIR/docker"
SKILLS_DIR="$SCRIPT_DIR/skills"
CONFIG_DIR="$SCRIPT_DIR/config"
CLAUDE_SKILLS="$HOME/.claude/skills"
ANTIGRAVITY_CONFIG="$HOME/.gemini/antigravity/mcp_config.json"

# ========================================
# Step 1: Check Prerequisites
# ========================================
echo ""
echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"

# Check Python 3.12
echo -n "  - Python 3.12... "
if command -v python3.12 &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
    PYTHON_CMD="python3.12"
elif python3 --version 2>&1 | grep -q "3.12"; then
    echo -e "${GREEN}OK${NC}"
    PYTHON_CMD="python3"
else
    echo -e "${RED}NOT FOUND${NC}"
    echo "    Install Python 3.12"
    exit 1
fi

# Check Docker
echo -n "  - Docker... "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}NOT FOUND${NC}"
    echo "    Install Docker"
    exit 1
fi

# ========================================
# Step 2: Install mcp-proxy
# ========================================
echo ""
echo -e "${YELLOW}[2/5] Installing mcp-proxy...${NC}"

if $PYTHON_CMD -m pip show mcp-proxy &> /dev/null; then
    echo -e "  ${GREEN}- mcp-proxy already installed${NC}"
else
    echo -e "  ${GRAY}- Installing mcp-proxy...${NC}"
    $PYTHON_CMD -m pip install mcp-proxy
    echo -e "  ${GREEN}- mcp-proxy installed${NC}"
fi

# ========================================
# Step 3: Setup Skills Symlink (Claude Code)
# ========================================
if [ "$SKIP_SKILLS" = false ] && [ "$ANTIGRAVITY_ONLY" = false ]; then
    echo ""
    echo -e "${YELLOW}[3/5] Setting up Claude Code skills symlink...${NC}"

    # Ensure .claude directory exists
    mkdir -p "$(dirname "$CLAUDE_SKILLS")"

    # Handle existing skills
    if [ -L "$CLAUDE_SKILLS" ]; then
        EXISTING_TARGET=$(readlink -f "$CLAUDE_SKILLS" 2>/dev/null || readlink "$CLAUDE_SKILLS")
        if [ "$EXISTING_TARGET" = "$SKILLS_DIR" ]; then
            echo -e "  ${GREEN}- Symlink already correct${NC}"
        else
            rm "$CLAUDE_SKILLS"
            ln -sf "$SKILLS_DIR" "$CLAUDE_SKILLS"
            echo -e "  ${GREEN}- Symlink updated${NC}"
        fi
    elif [ -d "$CLAUDE_SKILLS" ]; then
        BACKUP_PATH="${CLAUDE_SKILLS}.backup.$(date +%Y%m%d-%H%M%S)"
        mv "$CLAUDE_SKILLS" "$BACKUP_PATH"
        ln -sf "$SKILLS_DIR" "$CLAUDE_SKILLS"
        echo -e "  ${GREEN}- Existing skills backed up, symlink created${NC}"
    else
        ln -sf "$SKILLS_DIR" "$CLAUDE_SKILLS"
        echo -e "  ${GREEN}- Symlink created${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}[3/5] Skipping skills symlink${NC}"
fi

# ========================================
# Step 4: Start Docker Containers
# ========================================
if [ "$SKIP_DOCKER" = false ]; then
    echo ""
    echo -e "${YELLOW}[4/5] Starting Docker containers...${NC}"

    ENV_FILE="$DOCKER_DIR/.env"
    ENV_EXAMPLE="$DOCKER_DIR/.env.example"

    if [ ! -f "$ENV_FILE" ]; then
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        echo -e "  ${YELLOW}- Created .env from template${NC}"
        echo -e "  ${RED}- IMPORTANT: Edit docker/.env with your API keys!${NC}"
        echo ""
        echo -e "    ${YELLOW}Required keys:${NC}"
        echo -e "    ${GRAY}- N8N_API_URL, N8N_API_KEY${NC}"
        echo -e "    ${GRAY}- SUPABASE_ACCESS_TOKEN, SUPABASE_PROJECT_REF, etc.${NC}"
        echo -e "    ${GRAY}- CONTEXT7_API_KEY${NC}"
        echo -e "    ${GRAY}- GITHUB_TOKEN${NC}"
        echo -e "    ${GRAY}- TWENTYFIRST_API_KEY${NC}"
        echo ""
    fi

    pushd "$DOCKER_DIR" > /dev/null
    docker-compose up -d --build
    echo -e "  ${GREEN}- Docker containers started${NC}"
    popd > /dev/null
else
    echo ""
    echo -e "${YELLOW}[4/5] Skipping Docker${NC}"
fi

# ========================================
# Step 5: Configure MCP Servers
# ========================================
echo ""
echo -e "${YELLOW}[5/5] MCP Configuration...${NC}"

if [ "$CLAUDE_CODE_ONLY" = false ]; then
    echo ""
    echo -e "  ${CYAN}ANTIGRAVITY:${NC}"
    echo -e "  ${GRAY}Copy config/antigravity-mcp-config.json to:${NC}"
    echo -e "  $ANTIGRAVITY_CONFIG"
fi

if [ "$ANTIGRAVITY_ONLY" = false ]; then
    echo ""
    echo -e "  ${CYAN}CLAUDE CODE:${NC}"
    echo -e "  ${GRAY}Run these commands to add MCP servers:${NC}"
    echo "  claude mcp add n8n-docker -- $PYTHON_CMD -m mcp_proxy http://localhost:3001/sse"
    echo "  claude mcp add supabase-docker -- $PYTHON_CMD -m mcp_proxy http://localhost:3002/sse"
    echo "  claude mcp add github-docker -- $PYTHON_CMD -m mcp_proxy http://localhost:3003/sse"
    echo "  claude mcp add context7-docker -- $PYTHON_CMD -m mcp_proxy http://localhost:3004/sse"
    echo "  claude mcp add magic-docker -- $PYTHON_CMD -m mcp_proxy http://localhost:3005/sse"
fi

# ========================================
# Done
# ========================================
echo ""
echo -e "${GREEN}========================================"
echo "Setup Complete!"
echo -e "========================================${NC}"
echo ""
echo -e "${YELLOW}MCP Endpoints:${NC}"
echo -e "${GRAY}  n8n-mcp:      http://localhost:3001/sse${NC}"
echo -e "${GRAY}  supabase-mcp: http://localhost:3002/sse${NC}"
echo -e "${GRAY}  github-mcp:   http://localhost:3003/sse${NC}"
echo -e "${GRAY}  context7-mcp: http://localhost:3004/sse${NC}"
echo -e "${GRAY}  magic-mcp:    http://localhost:3005/sse${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "${GRAY}1. Edit docker/.env with your API keys${NC}"
echo -e "${GRAY}2. Restart your AI agent (Antigravity/Claude Code)${NC}"
echo -e "${GRAY}3. Test MCP tools${NC}"
