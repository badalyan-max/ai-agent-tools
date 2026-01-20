#!/bin/bash
#
# Setup development environment for a specific project.
#
# Usage:
#   ./setup-environment.sh <project> [--decrypt-env]
#
# Projects: cleanOS, craft-connect-buddy, websitenerstellung
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse arguments
PROJECT=""
DECRYPT_ENV=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --decrypt-env) DECRYPT_ENV=true ;;
        -h|--help)
            echo "Usage: $0 <project> [--decrypt-env]"
            echo ""
            echo "Projects:"
            echo "  cleanOS              Vite/React application"
            echo "  craft-connect-buddy  React Native/Expo mobile app"
            echo "  websitenerstellung   Next.js website"
            echo ""
            echo "Options:"
            echo "  --decrypt-env  Decrypt .env.enc to .env using SOPS"
            exit 0
            ;;
        *)
            if [[ -z "$PROJECT" ]]; then
                PROJECT=$1
            else
                echo "Unknown parameter: $1"
                exit 1
            fi
            ;;
    esac
    shift
done

# Validate project
if [[ -z "$PROJECT" ]]; then
    echo -e "${RED}ERROR: Project name required${NC}"
    echo "Usage: $0 <project> [--decrypt-env]"
    exit 1
fi

case $PROJECT in
    cleanOS|craft-connect-buddy|websitenerstellung)
        ;;
    *)
        echo -e "${RED}ERROR: Invalid project: $PROJECT${NC}"
        echo "Valid projects: cleanOS, craft-connect-buddy, websitenerstellung"
        exit 1
        ;;
esac

ENV_PATH="$SCRIPT_DIR/environments/$PROJECT"
TARGET_DIR="$(pwd)"

echo ""
echo -e "${CYAN}========================================"
echo "Setting up environment for: $PROJECT"
echo -e "========================================${NC}"
echo ""

# Check if environments directory exists
if [[ ! -d "$ENV_PATH" ]]; then
    echo -e "${RED}ERROR: Environment path not found: $ENV_PATH${NC}"
    exit 1
fi

# 1. Decrypt .env file (if requested)
if [[ "$DECRYPT_ENV" = true ]]; then
    ENC_FILE="$ENV_PATH/.env.enc"
    if [[ -f "$ENC_FILE" ]]; then
        echo -e "${YELLOW}[1/2] Decrypting .env file...${NC}"

        # Check if sops is available
        if ! command -v sops &> /dev/null; then
            echo -e "${RED}  SOPS not found. Install with: brew install sops${NC}"
            exit 1
        fi

        # Set SOPS_AGE_KEY_FILE if not already set
        if [[ -z "$SOPS_AGE_KEY_FILE" ]]; then
            export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
        fi

        # Check if age key exists
        if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
            echo -e "${RED}  Age key not found at: $SOPS_AGE_KEY_FILE${NC}"
            echo -e "${YELLOW}  Generate one with: age-keygen -o $SOPS_AGE_KEY_FILE${NC}"
            exit 1
        fi

        # Determine target .env location
        case $PROJECT in
            cleanOS)
                TARGET_ENV="$TARGET_DIR/.env"
                ;;
            craft-connect-buddy)
                TARGET_ENV="$TARGET_DIR/.env"
                ;;
            websitenerstellung)
                TARGET_ENV="$TARGET_DIR/shinytouch/.env.local"
                ;;
        esac

        sops -d "$ENC_FILE" > "$TARGET_ENV"
        echo -e "${GREEN}  Decrypted to: $TARGET_ENV${NC}"
    else
        echo -e "${GRAY}[1/2] No encrypted .env file found, skipping...${NC}"
    fi
else
    echo -e "${GRAY}[1/2] Skipping .env decryption (use --decrypt-env to enable)${NC}"
fi

# 2. Project-specific setup
echo -e "${YELLOW}[2/2] Installing dependencies...${NC}"

case $PROJECT in
    cleanOS)
        echo -e "${GRAY}  Copying package.json...${NC}"
        cp "$ENV_PATH/package.json" "$TARGET_DIR/package.json"

        echo -e "${GRAY}  Running npm install...${NC}"
        cd "$TARGET_DIR"
        npm install
        ;;

    craft-connect-buddy)
        echo -e "${GRAY}  Copying mobile/package.json...${NC}"

        if [[ ! -d "$TARGET_DIR/mobile" ]]; then
            echo -e "${RED}  ERROR: mobile/ directory not found${NC}"
            exit 1
        fi

        cp "$ENV_PATH/mobile-package.json" "$TARGET_DIR/mobile/package.json"

        echo -e "${GRAY}  Running npm install in mobile/...${NC}"
        cd "$TARGET_DIR/mobile"
        npm install
        ;;

    websitenerstellung)
        echo -e "${GRAY}  Copying shinytouch/package.json...${NC}"

        if [[ ! -d "$TARGET_DIR/shinytouch" ]]; then
            echo -e "${RED}  ERROR: shinytouch/ directory not found${NC}"
            exit 1
        fi

        cp "$ENV_PATH/package.json" "$TARGET_DIR/shinytouch/package.json"

        echo -e "${GRAY}  Running npm install in shinytouch/...${NC}"
        cd "$TARGET_DIR/shinytouch"
        npm install
        ;;
esac

echo ""
echo -e "${GREEN}========================================"
echo "Environment setup complete!"
echo -e "========================================${NC}"
echo ""
