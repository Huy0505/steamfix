#requires -Version 5.1
<#
    SteamFix v2 - sua loi Steam "-7: Khong the ket noi toi may chu"
    Cong cu dung chung: tu phat hien Steam, tu xin quyen Admin, co menu,
    co hoan tac, ghi log, khong can cai dat.

    Vi du:
        SteamFix-2.0.bat                     -> hien menu
        SteamFix-2.0.bat -Mode check         -> chi kiem tra
        SteamFix-2.0.bat -Mode fix -Unattended -NoPause   -> chay tu dong (IT)
        SteamFix-2.0.bat -Mode restore       -> tra DNS ve nhu cu
#>
[CmdletBinding()]
param(
    [ValidateSet('fix', 'check', 'restore')][string]$Mode,
    [switch]$Unattended,
    [switch]$NoPause,
    [switch]$Deep,
    [ValidateSet('vi', 'en')][string]$Lang
)

$ScriptVersion = '2.0.0'
$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

if ($env:OS -ne 'Windows_NT') { Write-Host 'SteamFix chi chay tren Windows.'; exit 3 }
if ($PSVersionTable.PSVersion.Major -lt 5) { Write-Host 'Can PowerShell 5.1 tro len.'; exit 3 }

# ============================ Da ngon ngu ============================
$S = @{
    vi = @{
        title = 'STEAM FIX v{0}  -  Loi -7: khong ket noi duoc may chu Steam'
        menu_q = 'Chon viec can lam:'
        opt1 = '1. Sua loi ngay (khuyen nghi)'
        opt2 = '2. Chi kiem tra, khong thay doi gi'
        opt3 = '3. Hoan tac - tra DNS ve nhu cu'
        opt0 = '0. Thoat'
        choose = 'Nhap lua chon [1]: '
        invalid = 'Lua chon khong hop le.'
        consent = 'Tool se: tat Steam, lam moi cache, xoa cache DNS, doi DNS sang 1.1.1.1/8.8.8.8, mo lai Steam. Tiep tuc?'
        yesno = '[Y/n] '
        aborted = 'Da huy. Khong thay doi gi.'
        need_admin = 'Thao tac nay can quyen Admin. Hay chuot phai file .bat > Run as administrator.'
        uac_cancel = 'Ban da huy hop thoai UAC -> khong the doi DNS. Tiep tuc phan con lai?'
        limited = 'Chay o che do gioi han (khong doi DNS).'
        step1 = '1/7 Kiem tra Internet va DNS'
        net_ok = 'Co ket noi Internet'
        net_warn = 'Khong ping/TCP ra ngoai (co the do tuong lua chan ICMP)'
        dns_ok = 'DNS phan giai duoc api.steampowered.com'
        dns_bad = 'DNS khong phan giai duoc ten mien Steam -> se doi DNS'
        net_dead = 'Mat ket noi Internet that su - kiem tra Wi-Fi/cap mang/tram phat roi chay lai.'
        step2 = '2/7 Tim thu muc Steam'
        steam_path = 'Steam: {0}'
        steam_missing = 'Khong tim thay Steam - bo qua phan cache va khoi dong lai.'
        step3 = '3/7 Tat Steam dang chay'
        running_none = 'Steam khong chay'
        kill_ok = 'Da tat: {0}'
        kill_fail = 'Van con tien trinh: {0}'
        step4 = '4/7 Lam moi cache HTML/app cua Steam'
        cache_done = 'Da lam moi: {0} (ban cu giu lai duoi ten .old_*)'
        cache_fail = 'Khong lam moi duoc {0}: {1}'
        step5 = '5/7 Xoa cache DNS va tat proxy'
        flush_ok = 'Da xoa cache DNS'
        flush_fail = 'flushdns loi: {0}'
        proxy_off = 'Da tat proxy trong Internet Settings'
        proxy_already = 'Proxy Internet Settings dang tat san'
        winhttp_ok = 'Da reset proxy WinHTTP'
        winhttp_fail = 'Reset proxy WinHTTP that bai (khong nghiem trong)'
        step6 = '6/7 Doi DNS sang 1.1.1.1 + 8.8.8.8'
        dns_set = 'Da dat DNS cho {0}: 1.1.1.1, 8.8.8.8'
        dns_fail = 'Dat DNS that bai: {0}'
        dns_skip = 'Bo qua doi DNS.'
        dns_noadmin = 'Khong co quyen Admin nen khong doi DNS duoc.'
        adapter_missing = 'Khong tim thay card mang dang hoat dong'
        dns_backup = 'DNS cu da luu de hoan tac: {0}'
        step7 = '7/7 Kiem tra may chu Steam'
        srv_ok = '{0} ({1}:{2}) - thong'
        srv_bad = '{0} ({1}:{2}) - KHONG thong'
        srv_none = 'Khong ket noi duoc may chu Steam nao -> mang/ISP chan hoac Steam dang bao tri.'
        steam_launch = 'Da khoi dong lai Steam - cho 10-20 giay roi dang nhap lai'
        steam_launch_fail = 'Khong mo lai duoc Steam: {0}'
        deep_done = 'Da reset winsock/TCP. Can khoi dong lai may de co tac dung.'
        done_ok = 'XONG. Mo Steam va thu dang nhap lai.'
        done_issues = 'Con {0} diem chua on (xem muc [X] o tren).'
        manual_hint = 'Neu van loi -7: Steam > Settings > Downloads > doi Download Region, hoac cho Steam het bao tri.'
        restored = 'Da tra DNS cua {0} ve: {1}'
        restored_dhcp = 'Da tra DNS cua {0} ve tu dong (DHCP)'
        restore_fail = 'Khong tra duoc DNS: {0}'
        restore_none = 'Chua co ban luu DNS de hoan tac.'
        restore_done = 'Da hoan tac xong.'
        logat = 'Log: {0}'
        press_enter = 'Nhan Enter de dong'
        not_admin_note = '(khong co quyen Admin - mot so buoc se bi bo qua)'
        sim_close = 'Se tat: {0}'
        sim_cache = 'Se lam moi cache: {0}'
        sim_net = 'Se flush DNS va tat proxy'
        check_done = 'Kiem tra xong - khong thay doi gi tren may.'
    }
    en = @{
        title = 'STEAM FIX v{0}  -  Error -7: cannot connect to Steam servers'
        menu_q = 'What do you want to do?'
        opt1 = '1. Fix it now (recommended)'
        opt2 = '2. Only check, change nothing'
        opt3 = '3. Undo - restore previous DNS'
        opt0 = '0. Exit'
        choose = 'Choose [1]: '
        invalid = 'Invalid choice.'
        consent = 'This will: close Steam, reset its cache, flush DNS, set DNS to 1.1.1.1/8.8.8.8, restart Steam. Continue?'
        yesno = '[Y/n] '
        aborted = 'Cancelled. Nothing changed.'
        need_admin = 'This action needs Administrator. Right-click the .bat > Run as administrator.'
        uac_cancel = 'UAC was cancelled -> cannot change DNS. Continue with the rest?'
        limited = 'Running in limited mode (no DNS change).'
        step1 = '1/7 Checking Internet and DNS'
        net_ok = 'Internet connection available'
        net_warn = 'No ping/TCP out (ICMP may be blocked)'
        dns_ok = 'DNS resolves api.steampowered.com'
        dns_bad = 'DNS cannot resolve Steam domains -> will change DNS'
        net_dead = 'No Internet at all - check Wi-Fi/cable/router and run again.'
        step2 = '2/7 Locating Steam'
        steam_path = 'Steam: {0}'
        steam_missing = 'Steam not found - skipping cache and relaunch.'
        step3 = '3/7 Closing Steam'
        running_none = 'Steam is not running'
        kill_ok = 'Closed: {0}'
        kill_fail = 'Still running: {0}'
        step4 = '4/7 Refreshing Steam HTML/app cache'
        cache_done = 'Refreshed: {0} (old copy kept as .old_*)'
        cache_fail = 'Could not refresh {0}: {1}'
        step5 = '5/7 Flushing DNS and disabling proxy'
        flush_ok = 'DNS cache flushed'
        flush_fail = 'flushdns failed: {0}'
        proxy_off = 'Disabled proxy in Internet Settings'
        proxy_already = 'Proxy already disabled'
        winhttp_ok = 'WinHTTP proxy reset'
        winhttp_fail = 'WinHTTP proxy reset failed (not critical)'
        step6 = '6/7 Setting DNS to 1.1.1.1 + 8.8.8.8'
        dns_set = 'DNS set on {0}: 1.1.1.1, 8.8.8.8'
        dns_fail = 'Setting DNS failed: {0}'
        dns_skip = 'Skipping DNS change.'
        dns_noadmin = 'No Administrator rights, DNS left unchanged.'
        adapter_missing = 'No active network adapter found'
        dns_backup = 'Previous DNS saved for undo: {0}'
        step7 = '7/7 Checking Steam servers'
        srv_ok = '{0} ({1}:{2}) - reachable'
        srv_bad = '{0} ({1}:{2}) - NOT reachable'
        srv_none = 'No Steam server reachable -> network/ISP block or Steam outage.'
        steam_launch = 'Steam restarted - wait 10-20 seconds, then sign in'
        steam_launch_fail = 'Could not restart Steam: {0}'
        deep_done = 'winsock/TCP reset. Reboot required.'
        done_ok = 'DONE. Open Steam and try signing in again.'
        done_issues = '{0} issue(s) remain (see [X] above).'
        manual_hint = 'Still error -7? Steam > Settings > Downloads > change Download Region, or wait out a Steam outage.'
        restored = 'DNS of {0} restored to: {1}'
        restored_dhcp = 'DNS of {0} restored to automatic (DHCP)'
        restore_fail = 'DNS restore failed: {0}'
        restore_none = 'No saved DNS backup to restore.'
        restore_done = 'Undo finished.'
        logat = 'Log: {0}'
        press_enter = 'Press Enter to close'
        not_admin_note = '(no Administrator rights - some steps skipped)'
        sim_close = 'Would close: {0}'
        sim_cache = 'Would refresh cache: {0}'
        sim_net = 'Would flush DNS and disable proxy'
        check_done = 'Check finished - nothing changed.'
    }
}

$L = if ($Lang) { $Lang } elseif ([System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName -eq 'vi') { 'vi' } else { 'en' }
if (-not $S.ContainsKey($L)) { $L = 'en' }

function T([string]$Key, [object[]]$A) {
    $t = $S[$L][$Key]
    if ($null -eq $t) { $t = $S['en'][$Key] }
    if ($null -eq $t) { return $Key }
    if ($A -and $A.Count) { try { return ($t -f $A) } catch { return $t } }
    return $t
}

# ============================ Trang thai, log ============================
# Thu muc lam viec: %LOCALAPPDATA%\SteamFix, khong ghi duoc thi lui ve %TEMP%.
function New-Dir([string]$p) {
    try { New-Item -ItemType Directory -Force -Path $p -ErrorAction Stop | Out-Null; return $true }
    catch { return $false }
}

$StateRoot = $null
foreach ($base in @($env:LOCALAPPDATA, $env:TEMP)) {
    if (-not $base) { continue }
    $cand = Join-Path $base 'SteamFix'
    if (New-Dir $cand) { $StateRoot = $cand; break }
}
if (-not $StateRoot) { $StateRoot = Join-Path (Split-Path -Parent $PSCommandPath) 'SteamFix-data' }
$null = New-Dir $StateRoot

$script:LogReady = $false
$LogDir = Join-Path $StateRoot 'logs'
if (New-Dir $LogDir) { $script:LogReady = $true }
$script:LogFile = Join-Path $LogDir ('steamfix-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$BackupFile = Join-Path $StateRoot 'dns-backup.json'

$script:Issues = 0
$script:Fixes = 0

function Log([string]$msg) {
    if (-not $script:LogReady) { return }
    try { Add-Content -LiteralPath $script:LogFile -Value ('[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $msg) -Encoding UTF8 -ErrorAction SilentlyContinue } catch { }
}
function Say([string]$m, [string]$color = 'Gray') { Write-Host $m -ForegroundColor $color; Log $m }
function Step([string]$m) { Write-Host ''; Write-Host ("== " + $m) -ForegroundColor Cyan; Log ("== " + $m) }
function Ok([string]$m) { Say ("   [OK] " + $m) 'Green' }
function Warn([string]$m) { Say ("   [!]  " + $m) 'Yellow' }
function Fail([string]$m) { Say ("   [X]  " + $m) 'Red'; $script:Issues++ }
function Info([string]$m) { Say ("   " + $m) 'DarkGray' }

function Test-Tcp {
    param([string]$Target, [int]$Port, [int]$TimeoutMs = 4000)
    $c = New-Object System.Net.Sockets.TcpClient
    try {
        $t = $c.ConnectAsync($Target, $Port)
        if ($t.Wait($TimeoutMs) -and $c.Connected) { return $true }
        return $false
    } catch { return $false } finally { try { $c.Dispose() } catch { } }
}

function Get-DefaultAdapter {
    # Adapter dang giu default route (metric thap nhat); fallback CIM neu thieu quyen.
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        $routes = @(Get-NetRoute -DestinationPrefix '0.0.0.0/0' 2>$null | Sort-Object { $_.RouteMetric + $_.InterfaceMetric } -ErrorAction SilentlyContinue)
        $cfgs = @(Get-NetIPConfiguration 2>$null | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' })
        foreach ($r in $routes) {
            $m = $cfgs | Where-Object { $_.InterfaceIndex -eq $r.InterfaceIndex } | Select-Object -First 1
            if ($m) { return $m }
        }
        if ($cfgs.Count -gt 0) { return $cfgs[0] }
    } catch { }
    finally { $ErrorActionPreference = $prev }
    try {
        $w = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' 2>$null |
             Where-Object { $_.DefaultIPGateway } | Select-Object -First 1
        if ($w) {
            return [pscustomobject]@{
                InterfaceIndex = [int]$w.InterfaceIndex
                InterfaceAlias = [string]$w.Description
                DnsServers     = @($w.DNSServerSearchOrder)
            }
        }
    } catch { }
    return $null
}

function Find-Steam {
    $cands = New-Object System.Collections.Generic.List[string]
    foreach ($k in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam')) {
        try { $p = (Get-ItemProperty -Path $k -Name InstallPath -ErrorAction Stop).InstallPath; if ($p) { $cands.Add($p) } } catch { }
    }
    foreach ($p in @("${env:ProgramFiles(x86)}\Steam", "$env:ProgramFiles\Steam", 'C:\Steam', 'D:\Steam', 'D:\Games\Steam', 'E:\Steam', 'E:\Games\Steam')) {
        if ($p) { $cands.Add($p) }
    }
    foreach ($p in $cands) {
        if ($p -and (Test-Path -LiteralPath (Join-Path $p 'steam.exe'))) { return $p }
    }
    return $null
}

function Get-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Restart-Elevated {
    $a = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ('"{0}"' -f $PSCommandPath))
    if ($Mode) { $a += @('-Mode', $Mode) }
    if ($Unattended) { $a += '-Unattended' }
    if ($NoPause) { $a += '-NoPause' }
    if ($Deep) { $a += '-Deep' }
    if ($Lang) { $a += @('-Lang', $Lang) }
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $a | Out-Null
}

# ============================ Giao dien ============================
Clear-Host
Write-Host ('=' * 56) -ForegroundColor Cyan
Write-Host ('  ' + (T 'title' @($ScriptVersion))) -ForegroundColor Cyan
Write-Host ('=' * 56) -ForegroundColor Cyan
Log ("SteamFix {0} | mode={1} | admin={2} | lang={3} | os={4}" -f $ScriptVersion, $Mode, (Get-IsAdmin), $L, [Environment]::OSVersion.VersionString)

if (-not $Mode) {
    if ($Unattended) {
        # Chay tu dong ma khong biet ro viec can lam -> dung, khong doan bua.
        Write-Host ' [-Mode fix|check|restore] is required with -Unattended.' -ForegroundColor Red
        Log 'Abort: -Unattended without -Mode'
        exit 2
    }
    Write-Host ''
    Write-Host (T 'menu_q')
    Write-Host (T 'opt1')
    Write-Host (T 'opt2')
    Write-Host (T 'opt3')
    Write-Host (T 'opt0')
    $c = Read-Host (T 'choose')
    switch ($c.Trim()) {
        '' { $Mode = 'fix' }
        '1' { $Mode = 'fix' }
        '2' { $Mode = 'check' }
        '3' { $Mode = 'restore' }
        '0' { Write-Host (T 'aborted'); return }
        default { Warn (T 'invalid'); return }
    }
}

$dryRun = ($Mode -eq 'check')
$isAdmin = Get-IsAdmin

if (-not $isAdmin -and -not $dryRun -and -not $Unattended) {
    Write-Host ''
    Write-Host (T 'need_admin') -ForegroundColor Yellow
    try { Restart-Elevated; return }
    catch {
        Warn (T 'uac_cancel')
        $ans = Read-Host (T 'yesno')
        if ($ans -and $ans.Trim().ToLower().StartsWith('n')) { Write-Host (T 'aborted'); return }
        Info (T 'limited')
    }
}
if (-not $isAdmin) { Info (T 'not_admin_note') }

# ---- Xac nhan truoc khi thay doi ----
if (-not $dryRun -and -not $Unattended) {
    Write-Host ''
    Write-Host (T 'consent') -ForegroundColor Yellow
    $ans = Read-Host (T 'yesno')
    if ($ans -and $ans.Trim().ToLower().StartsWith('n')) { Write-Host (T 'aborted'); if (-not $NoPause) { Read-Host (T 'press_enter') | Out-Null }; return }
}

# ============================ Hoan tac DNS ============================
if ($Mode -eq 'restore') {
    Step (T 'opt3')
    if (-not (Test-Path -LiteralPath $BackupFile)) { Warn (T 'restore_none') }
    else {
        try {
            $items = @(Get-Content -LiteralPath $BackupFile -Raw -Encoding UTF8 | ConvertFrom-Json)
            foreach ($it in $items) {
                try {
                    if ($it.Servers -and @($it.Servers).Count -gt 0) {
                        Set-DnsClientServerAddress -InterfaceIndex $it.InterfaceIndex -ServerAddresses @($it.Servers) -ErrorAction Stop
                        Ok (T 'restored' @($it.InterfaceAlias, (@($it.Servers) -join ', ')))
                    } else {
                        Set-DnsClientServerAddress -InterfaceIndex $it.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
                        Ok (T 'restored_dhcp' @($it.InterfaceAlias))
                    }
                    $script:Fixes++
                } catch { Fail (T 'restore_fail' @($_.Exception.Message)) }
            }
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            Move-Item -LiteralPath $BackupFile -Destination ($BackupFile + '.used') -Force -ErrorAction SilentlyContinue
            Ok (T 'restore_done')
        } catch { Fail (T 'restore_fail' @($_.Exception.Message)) }
    }
    Write-Host ''
    Info (T 'logat' @($script:LogFile))
    if (-not $NoPause) { Read-Host (T 'press_enter') | Out-Null }
    return
}

# ============================ 1. Internet / DNS ============================
Step (T 'step1')
$pingOk = $false
foreach ($h in @('1.1.1.1', '8.8.8.8')) {
    if (Test-Connection -ComputerName $h -Count 1 -Quiet -ErrorAction SilentlyContinue) { $pingOk = $true; break }
}
$tcpOk = (Test-Tcp '1.1.1.1' 443) -or (Test-Tcp '8.8.8.8' 443)

$dnsOk = $false
try { $dnsOk = ([System.Net.Dns]::GetHostAddresses('api.steampowered.com')).Count -gt 0 } catch { $dnsOk = $false }

if ($tcpOk -or $pingOk) { Ok (T 'net_ok') } else { Warn (T 'net_warn') }
if ($dnsOk) { Ok (T 'dns_ok') } else { Warn (T 'dns_bad') }

if (-not ($tcpOk -or $pingOk -or $dnsOk)) {
    Fail (T 'net_dead')
    Info (T 'logat' @($script:LogFile))
    if (-not $NoPause) { Read-Host (T 'press_enter') | Out-Null }
    exit 1
}

# ============================ 2. Steam ============================
Step (T 'step2')
$steamPath = Find-Steam
if ($steamPath) { Ok (T 'steam_path' @($steamPath)) } else { Warn (T 'steam_missing') }

# ============================ 3. Tat Steam ============================
Step (T 'step3')
$procs = @('steam', 'steamwebhelper', 'steamservice', 'GameOverlayUI', 'steamerrorreporter')
$running = @(Get-Process -Name $procs -ErrorAction SilentlyContinue)
$names = ($running | Select-Object -ExpandProperty ProcessName -Unique) -join ', '
if ($running.Count -eq 0) { Ok (T 'running_none') }
elseif ($dryRun) { Info (T 'sim_close' @($names)) }
else {
    foreach ($p in $running) { try { $p | Stop-Process -Force -ErrorAction SilentlyContinue } catch { } }
    Start-Sleep -Seconds 3
    $left = @(Get-Process -Name $procs -ErrorAction SilentlyContinue)
    if ($left.Count -eq 0) { Ok (T 'kill_ok' @($names)); $script:Fixes++ }
    else { Fail (T 'kill_fail' @((($left | Select-Object -ExpandProperty ProcessName -Unique) -join ', '))) }
    try { Stop-Service -Name 'Steam Client Service' -Force -ErrorAction SilentlyContinue } catch { }
}

# ============================ 4. Cache ============================
Step (T 'step4')
if (-not $steamPath) { Warn (T 'steam_missing') }
else {
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $dirs = @('htmlcache', 'appcache', 'config\htmlcache')
    if ($Deep) { $dirs += 'depotcache' }
    foreach ($rel in $dirs) {
        $dir = Join-Path $steamPath $rel
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        if ($dryRun) { Info (T 'sim_cache' @($rel)) }
        else {
            try {
                Rename-Item -LiteralPath $dir -NewName ((Split-Path $dir -Leaf) + ".old_$stamp") -Force
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                Ok (T 'cache_done' @($rel)); $script:Fixes++
            } catch { Fail (T 'cache_fail' @($rel, $_.Exception.Message)) }
        }
    }
    # don backup cu, giu 2 ban moi nhat moi noi
    foreach ($scan in @($steamPath, (Join-Path $steamPath 'config'))) {
        if (-not (Test-Path -LiteralPath $scan)) { continue }
        try {
            Get-ChildItem -LiteralPath $scan -Directory -Filter '*.old_*' -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -Skip 2 |
                ForEach-Object { if (-not $dryRun) { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue } }
        } catch { }
    }
}

# ============================ 5. DNS cache + proxy ============================
Step (T 'step5')
if ($dryRun) { Info (T 'sim_net') }
else {
    try { ipconfig /flushdns | Out-Null; Clear-DnsClientCache -ErrorAction SilentlyContinue; Ok (T 'flush_ok'); $script:Fixes++ }
    catch { Fail (T 'flush_fail' @($_.Exception.Message)) }

    try {
        $regProxy = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
        $old = (Get-ItemProperty -Path $regProxy -Name ProxyEnable -ErrorAction SilentlyContinue).ProxyEnable
        if ($old -eq 1) {
            Set-ItemProperty -Path $regProxy -Name ProxyEnable -Value 0 -Type DWord
            Ok (T 'proxy_off'); $script:Fixes++
        } else { Ok (T 'proxy_already') }
    } catch { Warn (T 'winhttp_fail') }

    try { netsh winhttp reset proxy 2>$null | Out-Null; Ok (T 'winhttp_ok') } catch { Warn (T 'winhttp_fail') }
}

# ============================ 6. Doi DNS ============================
Step (T 'step6')
if ($dryRun) { Info (T 'dns_skip') }
elseif (-not $isAdmin) { Warn (T 'dns_noadmin') }
else {
    $adapter = Get-DefaultAdapter
    if (-not $adapter) { Fail (T 'adapter_missing') }
    else {
        $idx = [int]$adapter.InterfaceIndex
        $alias = [string]$adapter.InterfaceAlias
        $current = @()
        try { $current = @((Get-DnsClientServerAddress -InterfaceIndex $idx -AddressFamily IPv4 -ErrorAction Stop).ServerAddresses) } catch { }
        if ($current.Count -eq 0 -and $adapter.DnsServers) { $current = @($adapter.DnsServers | Where-Object { $_ }) }

        # luu ban cu (ghi don, khong trung lap)
        $entries = @()
        if (Test-Path -LiteralPath $BackupFile) {
            try { $entries = @(Get-Content -LiteralPath $BackupFile -Raw -Encoding UTF8 | ConvertFrom-Json) } catch { $entries = @() }
        }
        $entries = @($entries | Where-Object { $_.InterfaceIndex -ne $idx })
        $entries += [pscustomobject]@{ InterfaceIndex = $idx; InterfaceAlias = $alias; Servers = @($current); SavedAt = (Get-Date).ToString('s') }
        try {
            New-Item -ItemType Directory -Force -Path $StateRoot | Out-Null
            ($entries | ConvertTo-Json -Depth 4) | Set-Content -LiteralPath $BackupFile -Encoding UTF8
            Info (T 'dns_backup' @($BackupFile))
        } catch { }

        try {
            Set-DnsClientServerAddress -InterfaceIndex $idx -ServerAddresses @('1.1.1.1', '8.8.8.8') -ErrorAction Stop
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            Ok (T 'dns_set' @($alias)); $script:Fixes++
        } catch { Fail (T 'dns_fail' @($_.Exception.Message)) }
    }
}

# ============================ 7. May chu Steam ============================
Step (T 'step7')
$targets = @(
    @{ Host = 'api.steampowered.com'; Port = 443; Ten = 'Steam API' },
    @{ Host = 'store.steampowered.com'; Port = 443; Ten = 'Steam Store' },
    @{ Host = 'cm0.steamserver.net'; Port = 27017; Ten = 'Steam CM' }
)
$reachable = 0
foreach ($t in $targets) {
    if (Test-Tcp $t.Host $t.Port 5000) { Ok (T 'srv_ok' @($t.Ten, $t.Host, $t.Port)); $reachable++ }
    else { Warn (T 'srv_bad' @($t.Ten, $t.Host, $t.Port)) }
}
if ($reachable -eq 0) { Fail (T 'srv_none') }

if ($Deep -and -not $dryRun) {
    try { netsh winsock reset 2>$null | Out-Null } catch { }
    try { netsh interface ip reset 2>$null | Out-Null } catch { }
    Warn (T 'deep_done')
}

if ($steamPath -and -not $dryRun) {
    $exe = Join-Path $steamPath 'steam.exe'
    if (Test-Path -LiteralPath $exe) {
        try { Start-Process -FilePath $exe -WorkingDirectory $steamPath; Ok (T 'steam_launch') }
        catch { Fail (T 'steam_launch_fail' @($_.Exception.Message)) }
    }
}

# ============================ Ket luan ============================
Write-Host ''
Write-Host ('=' * 56) -ForegroundColor Cyan
if ($dryRun) {
    Say (' ' + (T 'check_done')) 'Yellow'
}
elseif ($script:Issues -eq 0) {
    Say (' ' + (T 'done_ok')) 'Green'
}
else {
    Say (' ' + (T 'done_issues' @($script:Issues))) 'Yellow'
    Say (' ' + (T 'manual_hint')) 'Yellow'
}
Info (' ' + (T 'logat' @($script:LogFile)))
if ($isAdmin -and -not $dryRun) { Info (' ' + (T 'opt3')) }
Write-Host ('=' * 56) -ForegroundColor Cyan
Log ("Ket thuc: mode={0} fixes={1} issues={2}" -f $Mode, $script:Fixes, $script:Issues)

if ($script:Issues -gt 0) { $code = 1 } else { $code = 0 }
if (-not $NoPause) { Write-Host ''; Read-Host (T 'press_enter') | Out-Null }
exit $code
