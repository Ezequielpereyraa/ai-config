# install.ps1 — Sincroniza ai-config con ~/.claude en Windows
# Uso: .\install.ps1
# Intenta crear symlinks (requiere Developer Mode o admin).
# Si falla, copia los archivos directamente.

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "→ ai-config install desde: $RepoDir"
Write-Host "→ Target: $ClaudeDir"
Write-Host ""

if (-not (Test-Path $ClaudeDir)) {
    New-Item -ItemType Directory -Path $ClaudeDir | Out-Null
}

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
        [string]$RelDst
    )

    $src = Join-Path $RepoDir $RelSrc
    $dst = Join-Path $ClaudeDir $RelDst

    if (Test-Path $dst) {
        $backupPath = "$dst.backup"
        Write-Host "  backup: $dst → $backupPath"
        Move-Item -Path $dst -Destination $backupPath -Force
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
        [string]$Name
    )

    $src = Join-Path $RepoDir $Name
    $dst = Join-Path $ClaudeDir $Name

    if (Test-Path $dst) {
        $backupPath = "$dst.backup"
        Write-Host "  backup: $dst → $backupPath"
        Move-Item -Path $dst -Destination $backupPath -Force
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

Write-Host ""

if (-not $UseSymlinks) {
    Write-Host "⚠  Instalado con copias. Para sincronizar cambios futuros, corré este script de nuevo."
    Write-Host "   (Con symlinks, un 'git pull' alcanza — sin reinstalar)"
    Write-Host ""
}

Write-Host "✅ Listo. Reiniciá Claude Code para aplicar los cambios."
