# install.ps1 — Sincroniza ai-config con herramientas IA en Windows
# Uso: .\install.ps1
# Intenta crear symlinks (requiere Developer Mode o admin).
# Si falla, copia los archivos directamente.

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$OpenCodeDir = Join-Path $env:USERPROFILE ".config\opencode"
$CodexRulesDir = Join-Path $env:USERPROFILE ".codex\rules"

Write-Host "→ ai-config install desde: $RepoDir"
Write-Host "→ Claude target: $ClaudeDir"
Write-Host "→ OpenCode target: $OpenCodeDir"
Write-Host "→ Codex target: $CodexRulesDir"
Write-Host ""

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

if (-not (Test-Path $OpenCodeDir)) {
    New-Item -ItemType Directory -Path $OpenCodeDir | Out-Null
}

if (-not (Test-Path $CodexRulesDir)) {
    New-Item -ItemType Directory -Path $CodexRulesDir | Out-Null
}

function Remove-Stale-Symlink-Backups {
    param(
        [string]$Dir
    )

    Get-ChildItem -LiteralPath $Dir -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "*.backup" -and $_.LinkType -eq "SymbolicLink" } |
        Remove-Item -Force
}

Remove-Stale-Symlink-Backups $ClaudeDir
Remove-Stale-Symlink-Backups $OpenCodeDir
Remove-Stale-Symlink-Backups $CodexRulesDir

$UseSymlinks = $false
try {
    $testSrc = Join-Path $RepoDir "CLAUDE.md"
    $testDst = Join-Path $ClaudeDir "_symlink_test"
    New-Item -ItemType SymbolicLink -Path $testDst -Target $testSrc -ErrorAction Stop | Out-Null
    Remove-Item $testDst
    $UseSymlinks = $true
    Write-Host "  ✓ Symlinks disponibles (Developer Mode o admin detectado)"
} catch {
    Write-Host "  ⚠ Sin permisos para symlinks — usando Copy-Item como fallback"
    Write-Host "    (Para symlinks: activá Developer Mode en Configuración → Para desarrolladores)"
}

Write-Host ""

function Link-Or-Copy {
    param(
        [string]$RelSrc,
        [string]$RelDst,
        [string]$TargetDir = $ClaudeDir
    )

    $src = Join-Path $RepoDir $RelSrc
    $dst = Join-Path $TargetDir $RelDst

    if (Test-Path $dst) {
        $existing = Get-Item -LiteralPath $dst -Force
        if ($existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $src) {
            Remove-Item -LiteralPath $dst -Force
        } else {
            $backupPath = "$dst.backup"
            Write-Host "  backup: $dst → $backupPath"
            if (Test-Path $backupPath) { Remove-Item -Path $backupPath -Recurse -Force }
            Move-Item -Path $dst -Destination $backupPath
        }
    }

    if ($UseSymlinks) {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
        Write-Host "  ✓ (symlink) $dst → $src"
    } else {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "  ✓ (copy)    $dst ← $src"
    }
}

# Archivos principales
Link-Or-Copy "CLAUDE.md"     "CLAUDE.md"
Link-Or-Copy "settings.json" "settings.json"

# statusline.sh solo si existe
$statuslineSrc = Join-Path $RepoDir "statusline.sh"
if (Test-Path $statuslineSrc) {
    Link-Or-Copy "statusline.sh" "statusline.sh"
}

function Link-Or-Copy-Dir {
    param(
        [string]$RelSrc,
        [string]$RelDst = $RelSrc,
        [string]$TargetDir = $ClaudeDir
    )

    $src = Join-Path $RepoDir $RelSrc
    $dst = Join-Path $TargetDir $RelDst

    if (Test-Path $dst) {
        $existing = Get-Item -LiteralPath $dst -Force
        if ($existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $src) {
            Remove-Item -LiteralPath $dst -Force
        } else {
            $backupPath = "$dst.backup"
            Write-Host "  backup: $dst → $backupPath"
            if (Test-Path $backupPath) { Remove-Item -Path $backupPath -Recurse -Force }
            Move-Item -Path $dst -Destination $backupPath
        }
    }

    if ($UseSymlinks) {
        New-Item -ItemType SymbolicLink -Path $dst -Target $src | Out-Null
        Write-Host "  ✓ (symlink) $dst → $src"
    } else {
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        Write-Host "  ✓ (copy)    $dst ← $src"
    }
}

# Directorios completos
Link-Or-Copy-Dir "skills"
Link-Or-Copy-Dir "commands"
Link-Or-Copy-Dir "output-styles"

# OpenCode
$opencodeConfigSrc = Join-Path $RepoDir "opencode\opencode.jsonc"
if (Test-Path $opencodeConfigSrc) {
    Link-Or-Copy "opencode\opencode.jsonc" "opencode.jsonc" $OpenCodeDir
}
Link-Or-Copy-Dir "skills" "skills" $OpenCodeDir
Link-Or-Copy-Dir "commands" "commands" $OpenCodeDir

# Codex
$codexRulesSrc = Join-Path $RepoDir "codex\rules\default.rules"
if (Test-Path $codexRulesSrc) {
    Link-Or-Copy "codex\rules\default.rules" "default.rules" $CodexRulesDir
}

Write-Host ""

if (-not $UseSymlinks) {
    Write-Host "⚠  Instalado con copias. Para sincronizar cambios futuros, corré este script de nuevo."
    Write-Host "   (Con symlinks, un 'git pull' alcanza — sin reinstalar)"
    Write-Host ""
}

Write-Host "✅ Listo. Reiniciá Claude Code para aplicar los cambios."
