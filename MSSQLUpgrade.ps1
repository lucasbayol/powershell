### SQL2017Upgrade.ps1
### Version originale par someone 2020
### LB 02/06/2021 - Enlever le self elevate, ajouter le call operator pour l'installer de MSSQL,
### LB 03/06/2021 - Ajouter le téléchargement/extraction
### LB 22/07/2021 - Enlever le nettoyage des fichiers, modifier boucle IF, ajouter les règles de firewall, download de SSMS depuis le site officiel, 
###                 ajout de la verification des installations
           

Write-Host "Upgrade MSSQL11 vers MSSQL14 (2012 vers 2017) " -ForegroundColor Green

$InstanceName = Read-Host "Nom instance (si different DefaultInstanceName, sinon faites ENTER)"

if($InstanceName -contains ""){
    $InstanceName = "DefaultInstanceName"
}
New-Item -ItemType Directory -Path C:\NovoSQLUpgrade -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 
Write-Host "Telechargement des fichiers d'installation de MSSQL14"
$wc = New-Object net.webclient
$wc.Downloadfile("https://redacted/files/NovoSQLUpgrade.zip", "C:\NovoSQLUpgrade\NovoSQLUpgrade.zip") 
[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\NovoSQLUpgrade\NovoSQLUpgrade.zip","C:\NovoSQLUpgrade")

Write-Host "Mise à jour de MSSQL" 
& "C:\NovoSQLUpgrade\SQL_2017_EXPRADV_x64_ENU\setup.exe" /ACTION=upgrade /IACCEPTSQLSERVERLICENSETERMS /ENU /INSTANCENAME=$InstanceName /QUIETSIMPLE 
Write-Host "Telechargement et installation de SSMS 17"
$wc.Downloadfile("https://go.microsoft.com/fwlink/?linkid=2043154&clcid=0x409", "C:\NovoSQLUpgrade\SSMS-Setup-ENU.exe")
& C:\NovoSQLUpgrade\SSMS-Setup-ENU.exe /install /quiet /norestart /log "C:\NovoSQLUpgrade\Log\SSMS\SSMS-Install.log" | Out-Null

<# Checks if both installs worked properly #>
$ssmsparse = $null
$sqlparse = $null
$ssmsparse = Get-Content C:\NovoSQLUpgrade\Log\SSMS\SSMS-Install.log | Select-String -Pattern 'Shutting down, exit code: 0x0'
$sqlparse = Get-Content "C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\Summary.txt" | Select-String -Pattern "passed"
if (($ssmsparse) -and ($sqlparse)) {
Write-Host "Installation de SQL Server et SSMS a reussie"
} else {
Write-Host "Installation de SQL Server a echouee voir le log C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log  "
Write-Host "Installation de SSMS a echouee voir le log C:\NovoSQLUpgrade\Log\SSMS\SSMS-Install.log"
}

Write-Host "Ajout des regles de firewall" 
& C:\NovoSQLUpgrade\SQL.bat


       
   
 