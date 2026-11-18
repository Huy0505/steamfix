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

$docs = @('README.md', 'LICENSE', 'CHANGELOG.md', 'SECURITY.md')

$code  = Get-Content -LiteralPath $src -Raw -Encoding UTF8
# Ghi de so phien ban trong script bang -Version de ban phat hanh tu bao dung version.
$code  = [regex]::Replace($code, "\`$ScriptVersion = '[^']*'", "`$ScriptVersion = '$Version'")
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

# ---------- 2. Ban "plain": script doc duoc, khong base64 ----------
# Dung khi nguoi dung muon doc code truoc khi chay, va it bi AV soi hon.
$plainDir = Join-Path $dist '_plain'
New-Item -ItemType Directory -Force -Path $plainDir | Out-Null
Set-Content -LiteralPath (Join-Path $plainDir 'SteamFix.ps1') -Value $code -Encoding UTF8

$launcher = @'
@echo off
title SteamFix {VERSION}
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0SteamFix.ps1" %*
endlocal & exit /b %ERRORLEVEL%
'@.Replace('{VERSION}', $Version)
Set-Content -LiteralPath (Join-Path $plainDir 'Run-SteamFix.bat') -Value ($launcher -split "`r?`n") -Encoding ASCII
foreach ($f in $docs) {
    $p = Join-Path $root $f
    if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination $plainDir }
}
$plainZip = Join-Path $dist ("SteamFix-{0}-plain.zip" -f $Version)
Compress-Archive -Path (Join-Path $plainDir '*') -DestinationPath $plainZip -Force
Remove-Item -LiteralPath $plainDir -Recurse -Force

# ---------- 3. Checksum ----------
$sum = Join-Path $dist 'SHA256.txt'
$sumLines = @(
    ("{0} *{1}" -f (Get-FileHash -LiteralPath $bat -Algorithm SHA256).Hash, (Split-Path $bat -Leaf)),
    ("{0} *{1}" -f (Get-FileHash -LiteralPath $plainZip -Algorithm SHA256).Hash, (Split-Path $plainZip -Leaf))
)
Set-Content -LiteralPath $sum -Value $sumLines -Encoding ASCII

# ---------- 4. Zip phat hanh chinh ----------
$stage = Join-Path $dist '_stage'
New-Item -ItemType Directory -Force -Path $stage | Out-Null
Copy-Item -LiteralPath $bat -Destination $stage
Copy-Item -LiteralPath $sum -Destination $stage
foreach ($f in $docs) {
    $p = Join-Path $root $f
    if (Test-Path -LiteralPath $p) { Copy-Item -LiteralPath $p -Destination $stage }
}
$zip = Join-Path $dist ("SteamFix-{0}.zip" -f $Version)
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force
Remove-Item -LiteralPath $stage -Recurse -Force

# ---------- 5. Bao cao ----------
Write-Host ''
Write-Host ("Build xong v{0}" -f $Version) -ForegroundColor Green
Get-ChildItem -LiteralPath $dist -File | ForEach-Object {
    Write-Host ("  {0,-30} {1,8:N0} bytes" -f $_.Name, $_.Length)
}
$sumLines | ForEach-Object { Write-Host ("  " + $_) }
