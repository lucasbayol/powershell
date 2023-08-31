###Lucas Bayol august 2023 - List exchange rules that deletes spam emails instead of using Defender for 365 block list

$UPN = "UPN"
$antiSpamPolicy = "Anti spam policy"
$customerDomain = "customer domain"
import-module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName $UPN

#créer l'array des domaines dans l'anti-spam
$blockedDomains = $null
[System.Collections.ArrayList]$blockedDomains = @{}
#liste les domaines quis sont déjà bloqués 
$blockedDomains = ((Get-HostedContentFilterPolicy $antiSpamPolicy ).BlockedSenderDomains).domain
#liste les régles exchange qui delete les messages et sort les sender domains
$exchangeRuleDomains = (get-transportrule | Where-object {($_.DeleteMessage -eq $true -and $_.SubjectMatchesPatterns.count -eq 0 -and $_.State -eq "Enabled" -and $_.SenderDomainIs -gt 0 -and $_.SenderDomainIs -ne $customerDomain) }).SenderDomainIs
Write-Host "Listing the domains that needs to be added to the anti-spam policy"
foreach($exchangeRuleDomain in $exchangeRuleDomains){
    $blockedDomains.add($exchangeRuleDomain)
}
#array pour ajouter les domaines dans l'anti-spam
$domainsHT= @{add=$blockedDomains}
Set-HostedContentFilterPolicy "Opal - Anti-spam" -BlockedSenderDomains $domainsHT
#disable les règles Exchange superflues
Write-Host "Disabling the unnecessary rules"
Get-transportrule | Where-object {($_.DeleteMessage -eq $true -and $_.SubjectMatchesPatterns.count -eq 0 -and $_.State -eq "Enabled" -and $_.SenderDomainIs -gt 0 -and $_.SenderDomainIs -ne $customerDomain) } | Disable-TransportRule -confirm:$false
