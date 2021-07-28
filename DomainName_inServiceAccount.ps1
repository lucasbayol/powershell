$serviceaccount = Get-WmiObject win32_service | Select-Object -property Name, Startname
for ($i = 0; $i -le $serviceaccount.count; $i++){
if ($serviceaccount[$i] -match "$env:USERDOMAIN" ){
$serviceaccount[$i]
}
}