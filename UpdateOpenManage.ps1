$path = "C:\OpenManage" <# Path to default OpenManage self extract #>
function UpdateOpenManage {
Add-Type -AssemblyName System.IO.Compression.FileSystem <# Needed for replacement of Expand-Archive on older Powershell versions #>
$wc = New-Object net.webclient
$wc.Downloadfile("http://redacted/OpenManageUpdateMarch2021.zip", "C:\Users\$env:UserName\Documents\Update9.5.zip") <# Invoke-WebRequest for older Powershell versions and is WAY faster #>
[System.IO.Compression.ZipFile]::ExtractToDirectory("C:\Users\$env:UserName\Documents\Update9.5.zip","C:\Users\$env:UserName\Documents\Update9.5\") <# Expand-Archive on older Powershell versions #>
Move-Item -Path "C:\Users\$env:UserName\Documents\Update9.5" -Destination "C:\OpenManage\Update9.5" <# Move folder to $path because wget can't write to C: even if run as admin #>
Remove-Item -Path "C:\Users\$env:UserName\Documents\Update9.5.zip" <# delete original zip #>
msiexec /i C:\OpenManage\Update9.5\OpenManageUpdateMarch2021\SysMgmtx64.msi /qb | Out-Null <# Install/update OpenMange 9.5 unattend but show display bar | Wait till process finishes#>	
msiexec /update C:\OpenManage\Update9.5\OpenManageUpdateMarch2021\SysMgmt_9501_x64_patch_A00.msp /passive | Out-Null <# Install update 9.5.01 unattend but with progress bar #>
}
function CheckResults {
$result = omreport about | findstr -e 9.5.0.1 <# Check the OM version | grep at end of line #>
if ($result){
Write-Host "La mise a jour est installee"
} else {    
Write-Host "La mise a jour n'a pas reussis"
}
} <# Check if the update worked properly #>
 
if (Test-Path -Path $path){
UpdateOpenManage
CheckResults
} else {
New-Item -Path $path -ItemType Directory <# Create OpenManage folder if false #>
UpdateOpenManage
CheckResults
}
