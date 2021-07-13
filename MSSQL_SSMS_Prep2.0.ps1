### Script de préparation de MSSQL, SSMS, logiciel Server
### 21/05/2021 
### LB 9/6/2021   - Ajout du Requires admin rights
### LB 22/06/2021 - Ajout du téléchargement depuis serveur SFTP, téléchargement du DLL depuis webserver, 
### LB 23/06/2021 - modifier nom de variable pour représenter le contenu, vérification si zip existe, copie du SetupServer et Options Regionales, 
### LB 23/06/2021 - Nettoyage des fichiers d'installation, decode securestring pour WinSCP, modificaiton des fichiers de WinSCP
### collegue 25/06/2021 - Ajout commentaires + exemples + ajouté choix pour path de softprep
### LB 05/07/2021 - Téléchargement de SSMS directement de Microsoft
### LB 06/07/2021 - Modification des path d'installation de SSMS, MSSQL, recréer l'archive, modifier varaible success à global
### LB 08/07/2021 - Ajout de la copie des bases de donnees temporaire
### LB 09/07/2021 - Modification du mot de passe de l'archive
 
#Requires -RunAsAdministrator

Add-Type -AssemblyName System.IO.Compression.FileSystem <# Used to extract zip #>

$logiciel = Read-Host 'On installe un ou autre ?'
$absolute_path = Read-Host "Path absolu installation de logiciel server ex: C:\compagnie\un\logiciel (si vous n'entrez rien le path sera C:\compagnie\$logiciel\logiciel )"
$softprep_path = Read-host "Entrez le path du répertoire de preparation   ex: C:\compagnie (si vous n'entrez rien, le path sera C:\compagnie )"
$global:success=$false




<# Convert secure string in clear text for WinSCP #>
$securedpassword = Read-Host "Mot de passe " -AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedpassword)
$clearpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)


if ($absolute_path){
    if (test-path -path $absolute_path ){
        write-host "Le path est valide et sera utilisé "
        }
    else{
        write-host "Création du path $absolute_path"
        New-Item -ItemType Directory -Path $absolute_path -Force | Out-Null
        test-path -path $absolute_path
    }
}
else {
    $absolute_path = "C:\compagnie\$logiciel\logiciel"
    Write-Host "Creation du path de logiciel $absolute_path"
    New-Item -ItemType Directory -Path $absolute_path -Force | Out-Null

}


if ($softprep_path) {

    if (test-path -path $softprep_path ){
        write-host "Le path est valide et sera utilisé "
        }
    else{
        write-host "Création du path $softprep_path"
        New-Item -ItemType Directory -Path $softprep_path -Force | Out-Null
        test-path -path $softprep_path
    }
}
else {
    $softprep_path = 'C:\compagnie'
    Write-Host "Creation du path de preparation $softprep_path"
    New-Item -ItemType Directory -Path $softprep_path -Force | Out-Null

}


$zipexist = Test-Path -Path $softprep_path\logicielPrep.zip -PathType leaf

function LogParse{
$ssmsparse = $null
$sqlparse = $null
$ssmsparse = Get-Content $softprep_path\logicielPrep\Log\SSMS\SSMS-Install.log | Select-String -Pattern 'Shutting down, exit code: 0x0'
$sqlparse = Get-Content "C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log\Summary.txt" | Select-String -Pattern "passed"


if (($ssmsparse) -and ($sqlparse)) {
Write-Host "Installation de SQL Server et SSMS a reussie"
$global:success=$true
} else {

Write-Host "Installation de SQL Server a echouee voir le log C:\Program Files\Microsoft SQL Server\140\Setup Bootstrap\Log  "
Write-Host "Installation de SSMS a echouee voir le log C:\Users\username\Documents\logicielPrep\Log\SSMS\SSMS-Install.log"


}

}


[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 <# Force TLS 1.2 for webclient #>
$wc = New-Object net.webclient
$wc.Downloadfile("https://techcompagnie.xyz/files/WinSCP.zip", "$softprep_path\WinSCP.zip") <# To use WinSCP #>
[System.IO.Compression.ZipFile]::ExtractToDirectory("$softprep_path\WinSCP.zip","$softprep_path\WinSCP")

Remove-Item -Path $softprep_path\WinSCP.zip -Force 

        if (!$zipexist) {
            <# WinSCP generated #>
            Add-Type -Path $softprep_path\WinSCP\WinSCPnet.dll
            function FileTransferProgress
            {
                param($e)
             
                # Print transfer progress
                Write-Host -NoNewline ("`r{0} ({1:P0})" -f $e.FileName, $e.FileProgress)
            }
            
            
            # Configurer les options de session
            $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
                Protocol = [WinSCP.Protocol]::Sftp
                HostName = "dynamic dns"
                PortNumber = 9876
                UserName = "username"
                Password = $clearpassword
                SshHostKeyFingerprint = "ssh-ed25519 255 7S3BjFtxPSYeczmXFAX0Pbyc8e/E2jDY3TyWfVQq5qo="
            }
            
            $session = New-Object WinSCP.Session
            
            try
            {
                # Will continuously report progress of transfer
                $session.add_FileTransferProgress( { FileTransferProgress($_) } )
            
                $session.Open($sessionOptions)
            
                $session.GetFiles("/scp/logicielPrep.zip", "$softprep_path\*").Check()
            
                
            }
            finally
            {
                $session.Dispose()
            }
             <# End of WinSCP generated #>
            }


           
[System.IO.Compression.ZipFile]::ExtractToDirectory("$softprep_path\logicielPrep.zip","$softprep_path\")
Remove-Item -Path $softprep_path\logicielPrep.zip -Force

Set-Alias sz $softprep_path\7za.exe

Write-Host "Extraction en cours"
cd "$softprep_path"
sz x $softprep_path\logicielPrep.7z -o* -p"$clearpassword" | Out-Null

Write-Host "Installation de SQL Server"
& $softprep_path\logicielPrep\SQL_2017_EXPRADV_x64_ENU\setup.exe /ConfigurationFile=$softprep_path\logicielPrep\SQL_2017_EXPRADV_x64_ENU\ConfigurationFile.INI | Out-Null 

Write-Host "Telechargement et installation de SSMS"
$wc.Downloadfile("https://download.microsoft.com/download/4/6/8/4681f3b2-f327-4d3d-8617-264b20685be0/SSMS-Setup-ENU.exe", "$softprep_path\logicielPrep\SSMS-Setup-ENU.exe")
& $softprep_path\logicielPrep\SSMS-Setup-ENU.exe /install /quiet /norestart /log "$softprep_path\logicielPrep\Log\SSMS\SSMS-Install.log" | Out-Null 

Write-Host "Application des regles de firewall"
& $softprep_path\logicielPrep\SQL.bat | Out-Null

Write-Host "Application des options regionales"
& $softprep_path\logicielPrep\OptionsRegionales.bat | Out-Null

LogParse

Write-Host "Creation du dossier de Backup et copie des fichiers de sauvegarde SQL"
New-Item -ItemType Directory -Path $absolute_path'\Backup\scripts' -Force | Out-Null
Copy-Item -Path "$softprep_path\logicielPrep\SQL_Backup\*" -Destination $absolute_path'\Backup\scripts' | Out-Null

Write-Host "Creation du dossier d'installation logiciel"
New-Item -ItemType Directory -Path $absolute_path'\Installation' -Force | Out-Null

Write-Host "Copie du SetupServer dans le dossier d'installation logiciel"
Copy-Item -Path "$softprep_path\logicielPrep\SetupServer.exe" -Destination $absolute_path'\Installation\SetupServer.exe' | Out-Null

Write-Host "Copie du batch Options Regionales dans le dossier d'installation logiciel"
Copy-Item -Path "$softprep_path\logicielPrep\OptionsRegionales.bat" -Destination $absolute_path'\Installation\OptionsRegionales.bat' | Out-Null

Write-Host "Copie des bases de donnees temporaire "
if ($logiciel -match 'Ortho'){ 
Copy-Item -Path "$softprep_path\logicielPrep\BD_test_Ortho" -Destination $absolute_path'\BD_test_Ortho' -Recurse | Out-Null
} else {
Copy-Item -Path "$softprep_path\logicielPrep\BD_test_Dento" -Destination $absolute_path'\BD_test_Dento' -Recurse| Out-Null
}

Write-Host "Copie du script SQL"
Copy-Item -Path "$softprep_path\logicielPrep\Reset softUser dans toutes les bd.sql" -Destination $absolute_path'\Reset softUser dans toutes les bd.sql'  | Out-Null

if ($global:success){
    
    Write-Host "Nettoyage des fichiers d'installation"
    Remove-Item $softprep_path\logicielPrep
    Remove-Item -Path $softprep_path\logicielPrep.7z
    Remove-Item -Path $softprep_path\7za.exe
    
}




