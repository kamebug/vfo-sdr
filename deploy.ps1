# deploy.ps1 — VFO Antena & SDRangel
# Copia os arquivos da raiz pra docs/ (pasta servida pelo GitHub Pages) e faz commit/push.
# Uso:
#   .\deploy.ps1                          -> mensagem de commit padrão
#   .\deploy.ps1 -Message "ajusta favoritos"

param(
    [string]$Message = "Deploy: atualiza VFO"
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$docs = Join-Path $root "docs"

# Arquivos que compõem o app (edite aqui se adicionar novos arquivos no projeto)
$files = @("index.html", "manifest.json", "sw.js", "icon.svg")

Write-Host "==> Preparando docs/..." -ForegroundColor Cyan
if (-not (Test-Path $docs)) {
    New-Item -Path $docs -ItemType Directory | Out-Null
    Write-Host "  criado: docs/" -ForegroundColor Green
}

foreach ($f in $files) {
    $src = Join-Path $root $f
    if (-not (Test-Path $src)) {
        Write-Host "  AVISO: $f não encontrado na raiz, pulando." -ForegroundColor Yellow
        continue
    }
    Copy-Item -Path $src -Destination $docs -Force
    Write-Host "  copiado: $f" -ForegroundColor Green
}

# .nojekyll obrigatório pro GitHub Pages servir manifest.json/sw.js corretamente
$nojekyll = Join-Path $docs ".nojekyll"
if (-not (Test-Path $nojekyll)) {
    New-Item -Path $nojekyll -ItemType File | Out-Null
    Write-Host "  criado: docs/.nojekyll" -ForegroundColor Green
}

Write-Host "==> Git add/commit/push..." -ForegroundColor Cyan
git add .
git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Nada novo pra commitar (ou commit falhou) — seguindo pro push mesmo assim." -ForegroundColor Yellow
}
git push

Write-Host "==> Deploy concluído." -ForegroundColor Cyan
Write-Host "  Confira em Settings > Pages que a source está: branch 'main', pasta '/docs'." -ForegroundColor Cyan
