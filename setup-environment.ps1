<#
.SYNOPSIS
    Sets up development environment for a specific project.

.DESCRIPTION
    This script installs dependencies and optionally decrypts environment files
    for the specified project.

.PARAMETER Project
    The project to set up. Valid values: cleanOS, craft-connect-buddy, websitenerstellung

.PARAMETER DecryptEnv
    If specified, decrypts the .env.enc file to .env in the current directory.

.EXAMPLE
    .\setup-environment.ps1 -Project cleanOS
    Copies package.json and runs npm install

.EXAMPLE
    .\setup-environment.ps1 -Project cleanOS -DecryptEnv
    Additionally decrypts the .env file using SOPS
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("cleanOS", "craft-connect-buddy", "websitenerstellung")]
    [string]$Project,

    [switch]$DecryptEnv
)

$ErrorActionPreference = "Stop"
$EnvPath = "$PSScriptRoot\environments\$Project"
$TargetDir = Get-Location

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setting up environment for: $Project" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if environments directory exists
if (-not (Test-Path $EnvPath)) {
    Write-Host "ERROR: Environment path not found: $EnvPath" -ForegroundColor Red
    exit 1
}

# 1. Decrypt .env file (if requested and file exists)
if ($DecryptEnv) {
    $EncFile = "$EnvPath\.env.enc"
    if (Test-Path $EncFile) {
        Write-Host "[1/2] Decrypting .env file..." -ForegroundColor Yellow

        # Check if sops is available
        $sopsPath = Get-Command sops -ErrorAction SilentlyContinue
        if (-not $sopsPath) {
            Write-Host "  SOPS not found. Install with: winget install Mozilla.sops" -ForegroundColor Red
            exit 1
        }

        # Set SOPS_AGE_KEY_FILE if not already set
        if (-not $env:SOPS_AGE_KEY_FILE) {
            $env:SOPS_AGE_KEY_FILE = "$env:USERPROFILE\.config\sops\age\keys.txt"
        }

        # Check if age key exists
        if (-not (Test-Path $env:SOPS_AGE_KEY_FILE)) {
            Write-Host "  Age key not found at: $env:SOPS_AGE_KEY_FILE" -ForegroundColor Red
            Write-Host "  Generate one with: age-keygen -o $env:SOPS_AGE_KEY_FILE" -ForegroundColor Yellow
            exit 1
        }

        # Decrypt
        $targetEnv = switch ($Project) {
            "cleanOS" { "$TargetDir\.env" }
            "craft-connect-buddy" { "$TargetDir\.env" }
            "websitenerstellung" { "$TargetDir\shinytouch\.env.local" }
        }

        sops -d $EncFile | Out-File -FilePath $targetEnv -Encoding utf8
        Write-Host "  Decrypted to: $targetEnv" -ForegroundColor Green
    } else {
        Write-Host "[1/2] No encrypted .env file found, skipping..." -ForegroundColor Gray
    }
} else {
    Write-Host "[1/2] Skipping .env decryption (use -DecryptEnv to enable)" -ForegroundColor Gray
}

# 2. Project-specific setup
Write-Host "[2/2] Installing dependencies..." -ForegroundColor Yellow

switch ($Project) {
    "cleanOS" {
        Write-Host "  Copying package.json..." -ForegroundColor Gray
        Copy-Item "$EnvPath\package.json" "$TargetDir\package.json" -Force

        Write-Host "  Running npm install..." -ForegroundColor Gray
        Push-Location $TargetDir
        npm install
        Pop-Location
    }
    "craft-connect-buddy" {
        Write-Host "  Copying mobile/package.json..." -ForegroundColor Gray

        # Ensure mobile directory exists
        if (-not (Test-Path "$TargetDir\mobile")) {
            Write-Host "  ERROR: mobile/ directory not found" -ForegroundColor Red
            exit 1
        }

        Copy-Item "$EnvPath\mobile-package.json" "$TargetDir\mobile\package.json" -Force

        Write-Host "  Running npm install in mobile/..." -ForegroundColor Gray
        Push-Location "$TargetDir\mobile"
        npm install
        Pop-Location
    }
    "websitenerstellung" {
        Write-Host "  Copying shinytouch/package.json..." -ForegroundColor Gray

        # Ensure shinytouch directory exists
        if (-not (Test-Path "$TargetDir\shinytouch")) {
            Write-Host "  ERROR: shinytouch/ directory not found" -ForegroundColor Red
            exit 1
        }

        Copy-Item "$EnvPath\package.json" "$TargetDir\shinytouch\package.json" -Force

        Write-Host "  Running npm install in shinytouch/..." -ForegroundColor Gray
        Push-Location "$TargetDir\shinytouch"
        npm install
        Pop-Location
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Environment setup complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
