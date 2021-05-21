### Script de préparation de MSSQL, SSMS
### Fait par Lucas Bayol
### 21/05/2021 

$absolute_path = Read-Host 'Path absolut installation de redacted'
$absolute_check = Test-Path -Path $absolute_path
$testnovo_path = Test-Path -Path C:\redacted

if ($testnovo_path) {
Write-Host "Le path redacted existe"
} else {
Write-Host "Création du path redacted"
New-Item -ItemType Directory -Path C:\redacted -Force | Out-Null
}

function LogParse{
$ssmsparse = $null
$sqlparse = $null
$ssmsparse = Get-Content C:\redacted\Log\SSMS\SSMS-Install.log | Select-String -Pattern 'Shutting down, exit code: 0x0'
$sqlparse = Get-Content "C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\Summary.txt" | Select-String -Pattern "passed"


if (($ssmsparse) -and ($sqlparse)) {
Write-Host "Installation de SQL Server et SSMS a reussie"
} else {
Write-Host "Installation de SQL Server a echouee voir le log C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log  "
Write-Host "Installation de SSMS a echouee voir le log C:\redacted\Log\SSMS\SSMS-Install.log"
}

}

if ($absolute_check) {
    Set-Alias sz C:\redacted\7za.exe
    Add-Type -AssemblyName System.IO.Compression.FileSystem <# Needed for replacement of Expand-Archive on older Powershell versions #>
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 <# Force TLS 1.2 #>
    Write-Host "Telechargement en cours"
    $wc = New-Object net.webclient
    $wc.Downloadfile("https://redacted.zip", "C:\redacted\redacted.zip") <# Invoke-WebRequest for older Powershell versions and is WAY faster #>
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:\redacted.zip","C:\redacted\") <# Expand-Archive on older Powershell versions #>
    Write-Host "Extraction en cours"
    sz x C:\redacted.7z -oC:\redacted\ -p"redacted" | Out-Null
    Write-Host "Installation de SQL Server"
    & C:\redacted\SQL_2017_EXPRADV_x64_ENU\setup.exe /ConfigurationFile=C:\redacted\SQL_2017_EXPRADV_x64_ENU\ConfigurationFile.INI | Out-Null 
    Write-Host "Installation de SSMS"
    & C:\redacted\SSMS-Setup-ENU.exe /install /quiet /norestart /log "C:\redacted\Log\SSMS\SSMS-Install.log" | Out-Null 
    Write-Host "Application des regles de firewall"
    & C:\redacted\SQL.bat | Out-Null
    LogParse
    New-Item -ItemType Directory -Path $absolute_path'\Backup' -Force | Out-Null
    Copy-Item -Path "C:\redacted\SQL_Backup\*" -Destination $absolute_path'\Backup' | Out-Null
} else {
    Set-Alias sz C:\redacted\7za.exe
    Add-Type -AssemblyName System.IO.Compression.FileSystem <# Needed for replacement of Expand-Archive on older Powershell versions #>
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 <# Force TLS 1.2 #>
    Write-Host "Telechargement en cous"
    $wc = New-Object net.webclient
    $wc.Downloadfile("https://redacted.zip", "C:\redacted.zip") <# Invoke-WebRequest for older Powershell versions and is WAY faster #>
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:\redacted.zip","C:\redacted\") <# Expand-Archive on older Powershell versions #>
    Write-Host "Extraction en cours"
    sz x C:\redacted.7z -oC:\redacted\ -p"redacted" | Out-Null
    Write-Host "Installation de SQL Server"
    & C:\redacted\SQL_2017_EXPRADV_x64_ENU\setup.exe /ConfigurationFile=C:\redacted\SQL_2017_EXPRADV_x64_ENU\ConfigurationFile.INI | Out-Null 
    Write-Host "Installation de SSMS"
    & C:\redacted\SSMS-Setup-ENU.exe /install /quiet /norestart /log "C:\redacted\Log\SSMS\SSMS-Install.log" | Out-Null 
    Write-Host "Application des regles de firewall"
    & C:\redacted\SQL.bat | Out-Null
    LogParse
    New-Item -ItemType Directory -Path $absolute_path -Force | Out-Null
    New-Item -ItemType Directory -Path $absolute_path'\Backup' -Force | Out-Null
    Copy-Item -Path "C:\redacted\SQL_Backup\*" -Destination $absolute_path'\Backup' | Out-Null
}
