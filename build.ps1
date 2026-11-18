param(
    [string]$Version = '2.0.0'
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$src  = Join-Path $root 'src\Fix-Steam.ps1'
$dist = Join-Path $root 'dist'

if (-not (Test-Path -LiteralPath $src)) { throw "Thieu file nguon: $src" }
if (Test-Path $dist) { Remove-Item -LiteralPath $dist -Recurse -Force }
New-Item -ItemType Directory -Force -Path $dist | Out-Null

$code  = Get-Content -LiteralPath $src -Raw -Encoding UTF8
$bytes = [System.Text.Encoding]::UTF8.GetBytes($code)
$b64   = [Convert]::ToBase64String($bytes)

# ---------- 1. File .bat duy nhat (tu giai nen payload) ----------
$bat = Join-Path $dist ("SteamFix-{0}.bat" -f $Version)

$header = @'
@echo off
setlocal
chcp 65001 >nul
title SteamFix {VERSION}
set "SF_BAT=%~f0"
set "SF_PS1=%TEMP%\SteamFix_{VERSION}_%RANDOM%%RANDOM%.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$m='::===PAYLOAD===';$t=[IO.File]::ReadAllText($env:SF_BAT);$i=$t.LastIndexOf($m);if($i -lt 0){exit 9};$b64=$t.Substring($i+$m.Length) -replace '[^A-Za-z0-9+/=]','';try{[IO.File]::WriteAllBytes($env:SF_PS1,[Convert]::FromBase64String($b64))}catch{exit 9}"
if errorlevel 1 (
    echo.
    echo [X] Khong doc duoc noi dung tool. File co the bi sua hoac bi dien virus chan.
    echo     Hay tai lai file .bat tu nguon goc.
    pause
    exit /b 9
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%SF_PS1%" %*
set "SF_RC=%ERRORLEVEL%"
del /f /q "%SF_PS1%" >nul 2>&1
endlocal & exit /b %SF_RC%
::===PAYLOAD===
'@.Replace('{VERSION}', $Version)

$lines = New-Object System.Collections.Generic.List[string]
foreach ($l in ($header -split "`r?`n")) { $lines.Add($l) }
for ($i = 0; $i -lt $b64.Length; $i += 76) {
    $lines.Add($b64.Substring($i, [Math]::Min(76, $b64.Length - $i)))
}
Set-Content -LiteralPath $bat -Value $lines -Encoding ASCII

# ---------- 2. Zip phat hanh + checksum ----------
$hash = (Get-FileHash -LiteralPath $bat -Algorithm SHA256).Hash
$sum  = Join-Path $dist 'SHA256.txt'
Set-Content -LiteralPath $sum -Value ("{0} *{1}" -f $hash, (Split-Path $bat -Leaf)) -Encoding ASCII

$stage = Join-Path $dist '_stage'
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item -LiteralPath $bat -Destination $stage
Copy-Item -LiteralPath $sum -Destination $stage
foreach ($f in @('README.md', 'LICENSE', 'CHANGELOG.md')) {
    $p = Join-Path $root $f
    if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination $stage }
}
$zip = Join-Path $dist ("SteamFix-{0}.zip" -f $Version)
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force
Remove-Item -LiteralPath $stage -Recurse -Force

# ---------- 3. Bao cao ----------
Write-Host ''
Write-Host ("Build xong v{0}" -f $Version) -ForegroundColor Green
Get-ChildItem -LiteralPath $dist -File | ForEach-Object {
    Write-Host ("  {0,-26} {1,8:N0} bytes" -f $_.Name, $_.Length)
}
Write-Host ("  SHA256: {0}" -f $hash)
