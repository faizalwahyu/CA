# Requires Administrator

$Date = Get-Date -Format "yyyyMMdd_HHmmss"
$HostName = $env:COMPUTERNAME

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputDir = Join-Path $ScriptDir "CA_$HostName`_$Date"

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Write-Host "[+] Starting Collection"
Write-Host "[+] Output : $OutputDir"

####################################################
# SYSTEM
####################################################

$SystemDir = "$OutputDir\System"
New-Item -ItemType Directory $SystemDir -Force | Out-Null

systeminfo > "$SystemDir\systeminfo.txt"
hostname > "$SystemDir\hostname.txt"
ipconfig /all > "$SystemDir\ipconfig.txt"
route print > "$SystemDir\routes.txt"
arp -a > "$SystemDir\arp.txt"

####################################################
# USERS
####################################################

$UserDir = "$OutputDir\Users"
New-Item -ItemType Directory $UserDir -Force | Out-Null

net user > "$UserDir\local_users.txt"
net localgroup administrators > "$UserDir\administrators.txt"

query user > "$UserDir\logged_on_users.txt"

Get-LocalUser |
Export-Csv "$UserDir\local_users.csv" -NoTypeInformation

####################################################
# PROCESSES
####################################################

$ProcDir = "$OutputDir\Processes"
New-Item -ItemType Directory $ProcDir -Force | Out-Null

Get-Process |
Sort ProcessName |
Export-Csv "$ProcDir\processes.csv" -NoTypeInformation

tasklist /v > "$ProcDir\tasklist.txt"

Get-CimInstance Win32_Process |
Select Name,ProcessId,ExecutablePath,CommandLine |
Export-Csv "$ProcDir\commandline_processes.csv" -NoTypeInformation

####################################################
# SERVICES
####################################################

$SvcDir = "$OutputDir\Services"
New-Item -ItemType Directory $SvcDir -Force | Out-Null

Get-Service |
Export-Csv "$SvcDir\services.csv" -NoTypeInformation

wmic service get Name,State,StartMode,PathName `
/format:list > "$SvcDir\service_paths.txt"

####################################################
# NETWORK
####################################################

$NetDir = "$OutputDir\Network"
New-Item -ItemType Directory $NetDir -Force | Out-Null

netstat -ano > "$NetDir\netstat.txt"

Get-NetTCPConnection |
Export-Csv "$NetDir\tcp_connections.csv" -NoTypeInformation

####################################################
# SCHEDULED TASKS
####################################################

$TaskDir = "$OutputDir\ScheduledTasks"
New-Item -ItemType Directory $TaskDir -Force | Out-Null

schtasks /query /fo LIST /v > "$TaskDir\tasks.txt"

####################################################
# STARTUP
####################################################

$StartupDir = "$OutputDir\Startup"
New-Item -ItemType Directory $StartupDir -Force | Out-Null

Get-CimInstance Win32_StartupCommand |
Export-Csv "$StartupDir\startup_commands.csv" -NoTypeInformation

####################################################
# WMI PERSISTENCE
####################################################

$WMIDir = "$OutputDir\WMI"
New-Item -ItemType Directory $WMIDir -Force | Out-Null

Get-WmiObject `
-Namespace root\subscription `
-Class __EventFilter |
Out-File "$WMIDir\EventFilters.txt"

Get-WmiObject `
-Namespace root\subscription `
-Class CommandLineEventConsumer |
Out-File "$WMIDir\CommandLineConsumers.txt"

####################################################
# WINDOWS DEFENDER
####################################################

$DefenderDir = "$OutputDir\Defender"
New-Item -ItemType Directory $DefenderDir -Force | Out-Null

Get-MpComputerStatus |
Out-File "$DefenderDir\DefenderStatus.txt"

Get-MpThreatDetection |
Out-File "$DefenderDir\ThreatDetection.txt"

####################################################
# EVENT LOGS
####################################################

$EventDir = "$OutputDir\EventLogs"
New-Item -ItemType Directory $EventDir -Force | Out-Null

wevtutil epl Security "$EventDir\Security.evtx"
wevtutil epl System "$EventDir\System.evtx"
wevtutil epl Application "$EventDir\Application.evtx"

####################################################
# POWERSHELL
####################################################

$PSDir = "$OutputDir\PowerShell"
New-Item -ItemType Directory $PSDir -Force | Out-Null

wevtutil epl `
"Microsoft-Windows-PowerShell/Operational" `
"$PSDir\PowerShell.evtx"

####################################################
# IIS
####################################################

$IISDir = "$OutputDir\IIS"
New-Item -ItemType Directory $IISDir -Force | Out-Null

if(Test-Path "C:\inetpub\logs\LogFiles")
{
    Copy-Item `
    "C:\inetpub\logs\LogFiles" `
    $IISDir `
    -Recurse `
    -Force
}

####################################################
# PREFETCH
####################################################

$PrefetchDir = "$OutputDir\Prefetch"
New-Item -ItemType Directory $PrefetchDir -Force | Out-Null

if(Test-Path "C:\Windows\Prefetch")
{
    Copy-Item `
    "C:\Windows\Prefetch\*" `
    $PrefetchDir `
    -Force
}

####################################################
# REGISTRY HIVES
####################################################

$RegDir = "$OutputDir\Registry"
New-Item -ItemType Directory $RegDir -Force | Out-Null

reg save HKLM\SYSTEM `
"$RegDir\SYSTEM.hiv" /y

reg save HKLM\SOFTWARE `
"$RegDir\SOFTWARE.hiv" /y

reg save HKLM\SAM `
"$RegDir\SAM.hiv" /y

####################################################
# RECENT FILES
####################################################

$RecentDir = "$OutputDir\RecentFiles"
New-Item -ItemType Directory $RecentDir -Force | Out-Null

Get-ChildItem `
C:\ `
-Recurse `
-ErrorAction SilentlyContinue |
Where-Object {
$_.LastWriteTime -gt (Get-Date).AddDays(-30)
} |
Select FullName,LastWriteTime |
Export-Csv `
"$RecentDir\recent_files.csv" `
-NoTypeInformation

####################################################
# DRIVERS
####################################################

$DriverDir = "$OutputDir\Drivers"
New-Item -ItemType Directory $DriverDir -Force | Out-Null

driverquery /v > "$DriverDir\drivers.txt"

####################################################
# SHARES
####################################################

$ShareDir = "$OutputDir\Shares"
New-Item -ItemType Directory $ShareDir -Force | Out-Null

net share > "$ShareDir\shares.txt"

####################################################
# FIREWALL
####################################################

$FWDir = "$OutputDir\Firewall"
New-Item -ItemType Directory $FWDir -Force | Out-Null

netsh advfirewall show allprofiles `
> "$FWDir\firewall.txt"

####################################################
# ZIP
####################################################

Compress-Archive `
-Path $OutputDir `
-DestinationPath "$OutputDir.zip"

Get-FileHash `
"$OutputDir.zip" `
-Algorithm SHA256 |
Out-File "$OutputDir.zip.sha256"

Write-Host ""
Write-Host "[+] Collection Completed"
Write-Host "[+] Folder : $OutputDir"
Write-Host "[+] Archive: $OutputDir.zip"
Write-Host "[+] SHA256 : $OutputDir.zip.sha256"
