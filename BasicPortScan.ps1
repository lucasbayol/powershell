$ip = Read-Host "Host | IP "
$portlist = Read-Host "Quel ports souhaitez-vous vérifier séparer par virgule "
foreach ($port in $portlist.split(',')){ 

$scan = Test-NetConnection $ip -Port $port | Select-Object TcpTestSucceeded <# Full TCP on said port #>
if ( $scan )  <# no need to write equal true in PS #>
{
Write-Host "Le port $port est ouvert"  <# echo equivalent in PS #>
} else {
Write-Host "Le port $port est fermé"
}

}





