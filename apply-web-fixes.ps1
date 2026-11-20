$ErrorActionPreference = 'Stop'
Write-Host "Applying web assets fixes..."

# 1. Copy flutter_assets to web/assets
if (Test-Path "frontend/build/flutter_assets") {
    Copy-Item -Path "frontend/build/flutter_assets/*" -Destination "frontend/build/web/assets/" -Recurse -Force
    Write-Host "Copied flutter_assets to web/assets successfully."
}

# 2. Copy favicon and manifest
Copy-Item -Path "frontend/web/favicon.png" -Destination "frontend/build/web/" -Force
Copy-Item -Path "frontend/web/manifest.json" -Destination "frontend/build/web/" -Force
Write-Host "Copied favicon.png and manifest.json."

# 3. Patch flutter_bootstrap.js to use local CanvasKit and cache-busted mainJsPath
$bootstrapPath = "frontend/build/web/flutter_bootstrap.js"
if (Test-Path $bootstrapPath) {
    $content = Get-Content $bootstrapPath -Raw
    $ts = (Get-Date -Format "yyyyMMddHHmmss")
    $pattern = '(?s)_flutter\.buildConfig\s*=\s*\{.*?\};.*?\b_flutter\.loader\.load\(.*?\);'
    $replacement = '_flutter.buildConfig = {"engineRevision":"4c525dac5ebe5971c5708ef73558ed8edcf4a362","useLocalCanvasKit":true,"builds":[{"compileTarget":"dart2js","renderer":"canvaskit","mainJsPath":"main.dart.js?v=' + $ts + '"}]};' + "`r`n`r`n" + '_flutter.loader.load({config: {canvasKitBaseUrl: "canvaskit/"}});'
    $newContent = [regex]::Replace($content, $pattern, $replacement)
    Set-Content -Path $bootstrapPath -Value $newContent -NoNewline
    Write-Host "Patched flutter_bootstrap.js successfully with cache-buster v=$ts."
}

# 4. Copy custom index.html with PONDORA loading spinner and SW unregister
Copy-Item -Path "frontend/web/index.html" -Destination "frontend/build/web/index.html" -Force
Write-Host "Copied updated index.html with PONDORA loading spinner."

# 5. Ensure daytime ocean background image is placed in all candidate asset paths
$dayBgSrc = "frontend/assets/images/day_ocean_bg.png"
if (Test-Path $dayBgSrc) {
    New-Item -ItemType Directory -Force -Path "frontend/build/web/assets/assets/images" | Out-Null
    New-Item -ItemType Directory -Force -Path "frontend/build/web/assets/images" | Out-Null
    Copy-Item -Path $dayBgSrc -Destination "frontend/build/web/assets/assets/images/day_ocean_bg.png" -Force
    Copy-Item -Path $dayBgSrc -Destination "frontend/build/web/assets/images/day_ocean_bg.png" -Force
    Copy-Item -Path $dayBgSrc -Destination "frontend/build/web/day_ocean_bg.png" -Force
    Write-Host "Copied day_ocean_bg.png to all web asset paths."
}

Write-Host "All web post-build fixes applied successfully!"
